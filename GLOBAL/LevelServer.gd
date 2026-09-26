extends Control
class_name LevelServer

static var user: String = ""
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
  if await LevelServer.fetchRemotePublicKey(uname):
    ToastParty.err("that username is already taken")
    return false
  var kp = LevelServer.deriveKeypair(uname, password)
  if not await LevelServer.pushPublicKey(uname, Marshalls.raw_to_base64(kp.get_public_key())):
    ToastParty.err("failed to register username on the server")
    return false
  LevelServer.username = uname
  LevelServer.identityKey = kp
  ToastParty.success("registered as " + uname)
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
# GitHub plumbing (direct calls, using global.getToken() -- no relay yet)
# ---------------------------------------------------------------------------

static func githubHeaders() -> PackedStringArray:
  return PackedStringArray([
    "Authorization: token %s" % global.getToken(),
    "Content-Type: application/vnd.github.v3+json",
    "User-Agent: " + global.REPO_NAME
  ])

static func contentsUrl(path: String) -> String:
  return "https://api.github.com/repos/rsa17826/" + global.REPO_NAME + "/contents/" + global.urlEncode(path)

static func rawUrl(path: String) -> String:
  return "https://raw.githubusercontent.com/rsa17826/" + global.REPO_NAME + "/" + global.BRANCH + "/" + global.urlEncode(path) + "?rand=" + str(randf())

static func fetchRemotePublicKey(uname: String) -> String:
  if not uname: push_error("username required")
  var res = await global.httpGet(LevelServer.rawUrl("users/" + uname + ".pub"), PackedStringArray(), HTTPClient.METHOD_GET)
  if res.code == 200:
    return res.response
  return ""

static func pushPublicKey(uname: String, pubKeyB64: String) -> bool:
  var body = {
    "message": "register user " + uname,
    "content": Marshalls.raw_to_base64(pubKeyB64.to_utf8_buffer()),
    "branch": global.BRANCH
  }
  var res = await global.httpGet(LevelServer.contentsUrl("users/" + uname + ".pub"), LevelServer.githubHeaders(), HTTPClient.METHOD_PUT, JSON.stringify(body))
  return res.code == 200 or res.code == 201

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

  func _init(
    _levelName: String = '',
    _description: String = '',
    _creatorName: String = '',
    _gameVersion: int = -1,
    _levelVersion: int = -1,
    _levelData: PackedByteArray = [],
    _levelImage: Image = null,
    _completionInfo: String = '',
    _path: String = ''
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
    self.initing = false

static func levelPath(uname: String, levelName: String) -> String:
  return "levels/" + uname + "/" + levelName + ".json"

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

  var existingPath = LevelServer.levelPath(LevelServer.username, level.levelName)
  var existing = await LevelServer.loadMapByPath(existingPath)
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

  var url = LevelServer.contentsUrl(existingPath)
  var body = {
    "message": "upload level " + level.levelName + " v" + str(level.levelVersion),
    "content": Marshalls.raw_to_base64(JSON.stringify(payload).to_utf8_buffer()),
    "branch": global.BRANCH
  }
  var getRes = (await global.httpGet(url + "&rand=" + str(randf()), LevelServer.githubHeaders(), HTTPClient.METHOD_GET)).response
  if getRes and "sha" in getRes:
    body.sha = getRes.sha

  var putRes = await global.httpGet(url, LevelServer.githubHeaders(), HTTPClient.METHOD_PUT, JSON.stringify(body))
  if putRes.code == 200 or putRes.code == 201:
    ToastParty.success("File upload was successful!")
    return true
  else:
    log.err(putRes.code, putRes.response)
    ToastParty.error("File upload failed with error code: " + str(putRes.code))
    return false

static func dictToLevel(e: Dictionary, path: String) -> Level:
  var img: Image
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
  var data = JSON.parse_string(res.response)
  if not data:
    push_error("corrupt level file at " + path)
    return null
  var level = LevelServer.dictToLevel(data, path)
  var signature = Marshalls.base64_to_raw(data.signature)
  var signatureOk = LevelServer.verifyLevelSignature(level, signature, data.publicKey)
  var registryKey = await LevelServer.fetchRemotePublicKey(data.creatorName)
  level.verified = signatureOk and registryKey and registryKey.strip_edges() == data.publicKey.strip_edges()
  return level

static func fetchAllLevelPaths() -> Array:
  var url = "https://api.github.com/repos/rsa17826/" + global.REPO_NAME + "/git/trees/" + global.BRANCH + "?recursive=1"
  var res = (await global.httpGet(url, LevelServer.githubHeaders(), HTTPClient.METHOD_GET)).response
  if not res or not "tree" in res:
    return []
  var paths = []
  for entry in res.tree:
    if entry.path.begins_with("levels/") and entry.path.ends_with(".json"):
      paths.append(entry.path)
  return paths

# NOTE: this downloads every level's full JSON (including image + level data)
# just to build the list. Fine for a small number of levels; once the repo
# grows, add a lightweight levels/index.json manifest updated alongside each
# upload so listing doesn't require N full fetches.
static func loadAllLevels() -> Array:
  var levels = []
  for path in await LevelServer.fetchAllLevelPaths():
    var level = await LevelServer.loadMapByPath(path)
    if level:
      levels.append(level)
  return levels

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
