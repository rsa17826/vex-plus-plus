extends Control
class_name LevelServer

# ---------------------------------------------------------------------------
# Identity: the keypair is derived fresh, every login, from username+password.
# Nothing is stored locally -- log in from any device with just the password.
#
# Derivation: seed = blake2b iterated N times over (username:password).
# This is NOT a memory-hard KDF like Argon2id/scrypt (no such addon is
# available here), so it's weaker against offline guessing of a leaked/public
# registry entry than a proper password hash would be. Iteration count is a
# speed/security tradeoff -- raise it if login lag is acceptable, push users
# toward long passphrases either way, since that's what's actually carrying
# the security here.
# The PUBLIC key is what gets pushed to the repo at users/<name>.pub so
# anyone can verify who signed a level.
# ---------------------------------------------------------------------------

static var username: String = ""
static var identityKey: Ed25519Keypair = null

const KDF_ITERATIONS = 200000
const USERNAME_RE = "^[A-Za-z0-9_-]{3,32}$" # also what's safe to drop straight into a path / git ref / URL

static func tryRestoreLastSession():
  if global.mainMenu:
    global.mainMenu.currentUserInfoNode.text = "not logged in"

static func updateCurrentUserInfoNode():
  if global.mainMenu:
    if LevelServer.identityKey:
      global.mainMenu.currentUserInfoNode.text = "logged in as " + LevelServer.username
    else:
      global.mainMenu.currentUserInfoNode.text = "not logged in"

static func deriveSeed(uname: String, password: String) -> PackedByteArray:
  if not uname or not password:
    push_error("username and password required")
  var data = (uname + ":" + password).to_utf8_buffer()
  for i in KDF_ITERATIONS:
    data = Monocypher.blake2b(data)
  return data # 32 bytes -> Ed25519 seed

static func deriveKeypair(uname: String, password: String) -> Ed25519Keypair:
  var kp = Ed25519Keypair.from_seed(LevelServer.deriveSeed(uname, password))
  if not kp:
    push_error("failed to derive keypair from seed")
  return kp

# ---------------------------------------------------------------------------
# Register / login
# ---------------------------------------------------------------------------

static func register(uname: String, password: String) -> bool:
  if not uname or not password:
    ToastParty.err("username and password required")
    return false
  if not RegEx.create_from_string(USERNAME_RE).search(uname):
    ToastParty.err("usernames must be 3-32 characters: letters, numbers, - and _ only")
    return false
  if await LevelServer.fetchRemotePublicKey(uname):
    ToastParty.err("that username is already taken")
    return false
  var kp = LevelServer.deriveKeypair(uname, password)
  if not await LevelServer.pushPublicKey(uname, Marshalls.raw_to_base64(kp.get_public_key())):
    ToastParty.err("failed to submit username registration")
    return false
  LevelServer.username = uname
  LevelServer.identityKey = kp
  ToastParty.success(
    "registration for '" + uname + "' submitted -- it'll be usable once the " +
    "automatic checks pass and it merges (usually under a minute)"
  )
  return true

static func login(uname: String, password: String) -> bool:
  if not uname or not password:
    ToastParty.err("username and password required")
    return false
  var remotePubKeyB64 = await LevelServer.fetchRemotePublicKey(uname)
  if not remotePubKeyB64:
    ToastParty.err("username not found on the server")
    return false
  var kp = LevelServer.deriveKeypair(uname, password)
  if Marshalls.raw_to_base64(kp.get_public_key()) != remotePubKeyB64.strip_edges():
    ToastParty.err("wrong password for that username")
    return false
  LevelServer.username = uname
  LevelServer.identityKey = kp
  ToastParty.success("logged in as " + uname)
  return true

static func requestLogin() -> bool:
  var uname = await global.prompt("Please enter your username: ", global.PromptTypes.string)
  var password = await global.prompt("Please enter your password: ", global.PromptTypes.string)
  if await LevelServer.fetchRemotePublicKey(uname):
    return await LevelServer.login(uname, password)
  return await LevelServer.register(uname, password)

# ---------------------------------------------------------------------------
# GitHub plumbing (direct calls, using global.getToken() -- no relay)
#
# Nothing here pushes to the base branch directly anymore. Every write opens
# a branch + PR instead (see proposeFile below), because the repo now
# requires PRs on main and has a required status check (see
# scripts/validate_pr.py in the repo) that enforces who's allowed to touch
# what. A submission isn't live the instant this returns true -- it's live
# once that check passes and the PR auto-merges, which is usually fast but
# isn't instant. Reads (fetchRemotePublicKey, loadMapByPath, the manifest)
# still read straight off the base branch, so they reflect merged state only
# -- a PR that hasn't merged yet won't show up.
# ---------------------------------------------------------------------------

static func githubHeaders() -> PackedStringArray:
  return PackedStringArray([
    "Authorization: token %s" % global.getToken(),
    "Content-Type: application/vnd.github.v3+json",
    "User-Agent: " + global.REPO_NAME
  ])

static func apiUrl(suffix: String) -> String:
  return "https://api.github.com/repos/rsa17826/" + global.REPO_NAME + suffix

static func rawUrl(path: String) -> String:
  return "https://raw.githubusercontent.com/rsa17826/" + global.REPO_NAME + "/" + global.BRANCH + "/" + path + "?rand=" + str(randf())

static func fetchRemotePublicKey(uname: String) -> String:
  if not uname: push_error("username required")
  var res = await global.httpGet(LevelServer.rawUrl("users/" + global.urlEncode(uname) + ".pub"), PackedStringArray(), HTTPClient.METHOD_GET, "", null, false)
  if res.code == 200:
    return (res.response as PackedByteArray).get_string_from_utf8().strip_edges()
  return ""

static func sanitizeForRef(s: String) -> String:
  var out := ""
  for c in s:
    if c in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_":
      out += c
    else:
      out += "-"
  return out

# Opens a branch off the current base branch containing exactly one file
# add/update, then opens a PR for it against the base branch. Returns true
# only once the PR is actually open -- doesn't wait for or trigger the merge,
# that's validate-level-pr.yml's job once its check passes.
static func proposeFile(path: String, contentBytes: PackedByteArray, commitMessage: String, prTitle: String, prBody: String, branchPrefix: String) -> bool:
  var refRes = (await global.httpGet(LevelServer.apiUrl("/git/ref/heads/" + global.BRANCH), LevelServer.githubHeaders(), HTTPClient.METHOD_GET)).response
  if not refRes or not "object" in refRes:
    push_error("failed to read base branch ref")
    return false
  var baseCommitSha = refRes.object.sha

  var baseCommitRes = (await global.httpGet(LevelServer.apiUrl("/git/commits/" + baseCommitSha), LevelServer.githubHeaders(), HTTPClient.METHOD_GET)).response
  if not baseCommitRes or not "tree" in baseCommitRes:
    push_error("failed to read base commit")
    return false
  var baseTreeSha = baseCommitRes.tree.sha

  var blobRes = (await global.httpGet(
    LevelServer.apiUrl("/git/blobs"), LevelServer.githubHeaders(), HTTPClient.METHOD_POST,
    JSON.stringify({"content": Marshalls.raw_to_base64(contentBytes), "encoding": "base64"})
  )).response
  if not blobRes or not "sha" in blobRes:
    push_error("failed to create blob for " + path)
    return false

  var treeRes = (await global.httpGet(
    LevelServer.apiUrl("/git/trees"), LevelServer.githubHeaders(), HTTPClient.METHOD_POST,
    JSON.stringify({
      "base_tree": baseTreeSha,
      "tree": [ {"path": path, "mode": "100644", "type": "blob", "sha": blobRes.sha}]
    })
  )).response
  if not treeRes or not "sha" in treeRes:
    push_error("failed to create tree for " + path)
    return false

  var commitRes = (await global.httpGet(
    LevelServer.apiUrl("/git/commits"), LevelServer.githubHeaders(), HTTPClient.METHOD_POST,
    JSON.stringify({"message": commitMessage, "tree": treeRes.sha, "parents": [baseCommitSha]})
  )).response
  if not commitRes or not "sha" in commitRes:
    push_error("failed to create commit for " + path)
    return false

  var branchName = LevelServer.sanitizeForRef(branchPrefix) + "-" + str(Time.get_unix_time_from_system()).replace(".", "")
  var newRefRes = await global.httpGet(
    LevelServer.apiUrl("/git/refs"), LevelServer.githubHeaders(), HTTPClient.METHOD_POST,
    JSON.stringify({"ref": "refs/heads/" + branchName, "sha": commitRes.sha})
  )
  if newRefRes.code != 201:
    push_error("failed to create branch " + branchName)
    return false

  var prRes = await global.httpGet(
    LevelServer.apiUrl("/pulls"), LevelServer.githubHeaders(), HTTPClient.METHOD_POST,
    JSON.stringify({"title": prTitle, "head": branchName, "base": global.BRANCH, "body": prBody})
  )
  if prRes.code != 201:
    log.err(prRes.code, prRes.response)
    push_error("failed to open PR for " + path)
    return false
  return true

static func pushPublicKey(uname: String, pubKeyB64: String) -> bool:
  return await LevelServer.proposeFile(
    "users/" + uname + ".pub",
    pubKeyB64.to_utf8_buffer(),
    "register user " + uname,
    "Register user: " + uname,
    "Automated username registration.",
    "register-" + uname
  )

# ---------------------------------------------------------------------------
# Level model
# ---------------------------------------------------------------------------

class Level:
  signal dataChanged
  var initing = true
  var levelName: String = "":
    set(val):
      if not self.initing: dataChanged.emit()
      levelName = val
  var completionInfo: String = "":
    set(val):
      if not self.initing: dataChanged.emit()
      completionInfo = val
  var description: String = "":
    set(val):
      if not self.initing: dataChanged.emit()
      description = val
  var creatorName: String = "":
    set(val):
      if not self.initing: dataChanged.emit()
      creatorName = val
  var gameVersion: int:
    set(val):
      if not self.initing: dataChanged.emit()
      gameVersion = val
  var levelVersion: int:
    set(val):
      if not self.initing: dataChanged.emit()
      levelVersion = val
  var levelData: PackedByteArray:
    set(val):
      if not self.initing: dataChanged.emit()
      levelData = val
  var levelImage: Image:
    set(val):
      if not self.initing: dataChanged.emit()
      levelImage = val
  var path: String = "": # repo path, used as the unique id for this level
    set(val):
      if not self.initing: dataChanged.emit()
      path = val
  var verified: bool = false: # true if signature checks out AND matches the registry key
    set(val):
      if not self.initing: dataChanged.emit()
      verified = val
  var oldVersionCount: int = 0: # how many versions besides this one exist in history; from the manifest, 0 for anything loaded by exact path
    set(val):
      if not self.initing: dataChanged.emit()
      oldVersionCount = val

  func _init(
    _levelName: String = '',
    _description: String = '',
    _creatorName: String = '',
    _gameVersion: int = -1,
    _levelVersion: int = -1,
    _levelData: PackedByteArray = [],
    _levelImage: Image = null,
    _completionInfo: String = '',
    _path: String = '',
    _oldVersionCount: int = 0
  ):
    self.initing = true
    self.levelName = _levelName
    self.description = _description if _description else "NO DESCRIPTION SET"
    self.creatorName = _creatorName
    self.gameVersion = _gameVersion
    self.levelVersion = _levelVersion
    self.levelData = _levelData
    self.levelImage = _levelImage
    self.completionInfo = _completionInfo
    self.path = _path
    self.oldVersionCount = _oldVersionCount
    self.initing = false

# "Latest" is the file the manifest and the browse list point at -- it always
# holds whatever was uploaded most recently. Every upload ALSO writes an
# immutable copy under historyLevelPath, named by its own levelVersion, so
# old versions stay fetchable even after a newer one overwrites latest (see
# loadOldVersions). The validator (scripts/validate_pr.py) requires both
# paths be touched together with byte-identical content, so the two can
# never drift apart.
static func latestLevelPath(uname: String, levelName: String) -> String:
  return "levels/" + uname + "/" + LevelServer.sanitizeForRef(levelName) + ".json"

static func historyLevelPath(uname: String, levelName: String, version: int) -> String:
  return "levels/" + uname + "/" + LevelServer.sanitizeForRef(levelName) + "/" + str(version) + ".json"

# ---------------------------------------------------------------------------
# Signing / verification
# ---------------------------------------------------------------------------

static func canonicalLevelBytes(level: Level) -> PackedByteArray:
  var out := PackedByteArray()
  out.append_array(level.levelName.to_utf8_buffer())
  out.append(0)
  out.append_array(level.creatorName.to_utf8_buffer())
  out.append(0)
  out.append_array(str(level.gameVersion).to_utf8_buffer())
  out.append(0)
  out.append_array(str(level.levelVersion).to_utf8_buffer())
  out.append(0)
  out.append_array(level.levelData)
  return out

static func signLevel(level: Level) -> PackedByteArray:
  if not LevelServer.identityKey:
    push_error("must be logged in to sign a level")
    return PackedByteArray()
  return Ed25519.sign(LevelServer.canonicalLevelBytes(level), LevelServer.identityKey.get_seed(), LevelServer.identityKey.get_public_key())

static func verifyLevelSignature(level: Level, signature: PackedByteArray, pubKeyB64: String) -> bool:
  var pubKey = Marshalls.base64_to_raw(pubKeyB64)
  if pubKey.size() != 32:
    push_error("invalid public key for " + level.creatorName)
    return false
  return Ed25519.verify(signature, LevelServer.canonicalLevelBytes(level), pubKey)

# ---------------------------------------------------------------------------
# Upload / download
# ---------------------------------------------------------------------------

static func uploadLevel(level: Level) -> bool:
  if global.useropts.confirmLevelUploads \
  and not await global.prompt(
    "Are you sure you want to upload \"" + level.levelName + "\" by \"" + level.creatorName + "\"?",
    global.PromptTypes.confirm
  ): return false
  if not LevelServer.identityKey and not await LevelServer.requestLogin(): return false
  level.creatorName = LevelServer.username

  var path = LevelServer.latestLevelPath(LevelServer.username, level.levelName)
  # Reads the merged state on the base branch -- a prior upload still stuck
  # in an unmerged PR won't show up here, so this can't catch every race,
  # but it catches the common "I already uploaded this" case.
  var existing = await LevelServer.loadMapByPath(path)
  if existing and existing.levelVersion >= level.levelVersion:
    global.prompt(
      "this level you are trying to upload is not newer than the version already uploaded" +
      "\n\n ONLINE LEVEL VERSION: " + str(existing.levelVersion) +
      ' - LOCAL LEVEL VERSION: ' + str(level.levelVersion),
      global.PromptTypes.info
    )
    return false

  var signature = LevelServer.signLevel(level)
  var payload = {
    "levelName": level.levelName,
    "description": level.description,
    "creatorName": LevelServer.username,
    "gameVersion": level.gameVersion,
    "levelVersion": level.levelVersion,
    "levelData": Marshalls.raw_to_base64(level.levelData),
    "levelImage": Marshalls.raw_to_base64(level.levelImage.save_png_to_buffer()),
    "publicKey": Marshalls.raw_to_base64(LevelServer.identityKey.get_public_key()),
    "signature": Marshalls.raw_to_base64(signature)
  }

  var ok = await LevelServer.proposeFile(
    path,
    JSON.stringify(payload).to_utf8_buffer(),
    "upload level " + level.levelName + " v" + str(level.levelVersion),
    "Upload level: " + level.levelName + " v" + str(level.levelVersion) + " by " + LevelServer.username,
    "Automated level upload.",
    "upload-" + LevelServer.username
  )
  if ok:
    ToastParty.success(
      "Level submitted! It'll show up once the automatic checks pass and it merges " +
      "(usually under a minute)."
    )
    return true
  else:
    ToastParty.error("Failed to submit level for upload.")
    return false

static func dictToLevel(e: Dictionary, path: String) -> Level:
  var img: Image = Image.new()
  if 'levelImage' in e:
    if not e.levelImage:
      img = ResourceLoader.load("res://scenes/blocks/image.png").get_image()
    elif e.levelImage is Image:
      img = e.levelImage
    else:
      img = Image.new()
      img.load_png_from_buffer(Marshalls.base64_to_raw(e.levelImage))
  var levelData: PackedByteArray = Marshalls.base64_to_raw(e.levelData) if "levelData" in e else PackedByteArray()
  return Level.new(
    e.levelName,
    e.description,
    e.creatorName,
    e.gameVersion,
    e.levelVersion,
    levelData,
    img,
    e.get("completionInfo", ""),
    path
  )

static func loadMapByPath(path: String) -> Level:
  var res = await global.httpGet(LevelServer.rawUrl(path), PackedStringArray(), HTTPClient.METHOD_GET)
  if res.code != 200 or not res.response: return null
  var data = res.response
  if not data:
    push_error("corrupt level file at " + path)
    return null
  var level = LevelServer.dictToLevel(data, path)
  var signature = Marshalls.base64_to_raw(data.signature)
  var signatureOk = LevelServer.verifyLevelSignature(level, signature, data.publicKey)
  var registryKey = await LevelServer.fetchRemotePublicKey(data.creatorName)
  level.verified = signatureOk and registryKey and registryKey.strip_edges() == data.publicKey.strip_edges()
  return level

static func loadAllLevels(force: bool) -> Array:
  var res = (await global.httpGet("https://api.github.com/repos/rsa17826/" + global.REPO_NAME + "/contents/meta/manifest.json?ref=" + global.BRANCH, PackedStringArray(["Authorization: token " + global.getToken(),
    "Accept: application/vnd.github.v3.raw",
    "Cache-Control: no-cache",
    "Pragma: no-cache"
  ]), HTTPClient.METHOD_GET) if force else await global.httpGet(LevelServer.rawUrl("meta/manifest.json"), PackedStringArray(), HTTPClient.METHOD_GET))
  if res.code != 200 or not res.response:
    push_error("failed to load levels manifest")
    return []
  var data = res.response
  if not data or not "levels" in data:
    push_error("corrupt levels manifest")
    return []
  var levels = []
  for e in data.levels:
    levels.append(LevelServer.dictToLevel(e, e.path))
  LevelServer.loadLevelImages(levels) # not awaited -- images fill in progressively via dataChanged
  return levels

static func cachePath(path: String) -> String:
  # path (e.g. "levels/alice/my-level.json") has slashes, so it isn't a safe
  # filename as-is -- hash it the same way identityPath() hashes usernames.
  return global.path.abs("user://cache/levelImages/" + path.sha256_text() + ".png")

# Manifest entries carry no levelImage (dictToLevel leaves it null for them),
# so this fills images in after the fact: disk cache first, then fetch
# whatever's missing. GitHub raw files can't be fetched by field the way the
# old Supabase query selected just ['id','levelImage'], so each miss pulls
# that level's whole JSON (levelData included) just for the image -- wasteful
# for large levels. If that starts to matter, consider publishing images as
# their own levels/<name>/<level>.png alongside the JSON so they can be
# fetched independently; that's a bigger change (touches the signing payload
# and the validator) so it's not done here.
static func loadLevelImages(levels: Array) -> void:
  var toFetch: Array = []
  for level: Level in levels:
    var cp = LevelServer.cachePath(level.path)
    if FileAccess.file_exists(cp):
      level.levelImage = Image.load_from_file(cp)
      level.dataChanged.emit.call_deferred()
    else:
      toFetch.append(level)
  if toFetch.is_empty(): return
  DirAccess.make_dir_recursive_absolute(global.path.abs("user://cache/levelImages/"))
  # first one awaited alone so something shows up on screen quickly, the rest
  # fired off concurrently in waves rather than one big burst or a slow
  # strictly-sequential loop
  await LevelServer.fetchAndCacheImage(toFetch[0])
  for level in toFetch.slice(1, 6):
    LevelServer.fetchAndCacheImage(level) # not awaited: runs concurrently
  for level in toFetch.slice(6):
    LevelServer.fetchAndCacheImage(level) # not awaited: runs concurrently

static func fetchAndCacheImage(level: Level) -> void:
  var res = await global.httpGet(LevelServer.rawUrl(level.path), PackedStringArray(), HTTPClient.METHOD_GET)
  if res.code != 200 or not res.response or not "levelImage" in res.response or not res.response.levelImage: return
  var img = Image.new()
  img.load_png_from_buffer(Marshalls.base64_to_raw(res.response.levelImage))
  level.levelImage = img
  img.save_png(LevelServer.cachePath(level.path))
  level.dataChanged.emit()

static func downloadMap(level: LevelServer.Level) -> bool:
  var full = await LevelServer.loadMapByPath(level.path)
  if not full:
    ToastParty.error("Download failed, the map " + level.levelName + " by " + level.creatorName + " doesn't exist.")
    return false
  var f = FileAccess.open(global.path.abs("res://downloaded maps/" + full.levelName + '.vex++'), FileAccess.WRITE)
  f.store_buffer(full.levelData)
  f.close()
  if await global.tryAndGetMapZipsFromArr([global.path.abs("res://downloaded maps/" + full.levelName + '.vex++')]):
    ToastParty.success("Download complete\nthe map " + full.levelName + " by " + full.creatorName + " has been loaded.")
    return true
  else:
    ToastParty.error("Download failed, the map " + full.levelName + " by " + full.creatorName + " was invalid.")
  return false
