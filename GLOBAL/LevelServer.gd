extends Control
class_name LevelServer

static var user: SupabaseUser = null

static func register(uname: String, password: String) -> SupabaseUser:
  if !('@' in uname):
    uname += "@null.nosite"
  var authTask: AuthTask = await Supabase.auth.sign_up(
    uname,
    password
  ).completed
  log.pp(authTask.user)
  if authTask.user:
    ToastParty.success("logged in")
  else:
    ToastParty.err("failed to login")
  user = authTask.user
  return authTask.user


static func login(uname: String, password: String) -> SupabaseUser:
  if !('@' in uname):
    uname += "@null.nosite"
  var authTask: AuthTask = await Supabase.auth.sign_in(
    uname,
    password
  ).completed
  # log.pp(authTask.user)
  if authTask.user:
    ToastParty.success("logged in")
  else:
    ToastParty.err("failed to login")
  user = authTask.user
  return authTask.user

static func query(query: SupabaseQuery):
  return (await Supabase.database.query(query).completed).data

class Level:
  var levelName: String = ""
  var description: String = ""
  var creatorId: String = ""
  var creatorName: String = ""
  var gameVersion: int
  var onlineId: int
  var levelVersion: int
  var levelData: PackedByteArray
  var levelImage: Image
  var oldVersionCount: int = 0
  func _init(
    _levelName: String = '',
    _onlineId: int = -1,
    _description: String = '',
    _creatorId: String = '',
    _creatorName: String = '',
    _gameVersion: int = -1,
    _levelVersion: int = -1,
    _levelData: PackedByteArray = [],
    _levelImage: Image = null
  ):
    self.levelName = _levelName
    self.description = _description if _description else "NO DESCRIPTION SET"
    self.onlineId = _onlineId
    self.creatorId = _creatorId
    self.creatorName = _creatorName
    self.gameVersion = _gameVersion
    self.levelVersion = _levelVersion
    self.levelData = _levelData
    self.levelImage = _levelImage

  func setName(val):
    self.levelName = val
    return self
  func setDesc(val):
    self.description = val if val else "NO DESCRIPTION SET"
    return self
  func setCreatorName(val):
    self.creatorName = val
    return self
  func setData(val):
    self.levelData = val
    return self
  func setGameVersion(val):
    self.gameVersion = val
    return self
  func setLevelVersion(val):
    self.levelVersion = val
    return self

static func requestLogin() -> SupabaseUser:
  user = await LevelServer.login(
    await global.prompt("Please enter your username: ", global.PromptTypes.string),
    await global.prompt("Please enter your password: ", global.PromptTypes.string)
  )
  return user

static func uploadLevel(level: Level):
  if not user: await LevelServer.requestLogin()
  var levels = await LevelServer.doesLevelExist(level)
  if levels:
    for uploadedLevel in levels:
      if uploadedLevel.levelVersion >= level.levelVersion:
        global.prompt(
          "this level you are trying to upload is not newer than the version already uploaded" +
          "\n\n ONLINE LEVEL VERSION: " + str(uploadedLevel.levelVersion) +
          ' - LOCAL LEVEL VERSION: ' + str(level.levelVersion),
          global.PromptTypes.info
        )
        return
  log.pp(levels)
  return await Supabase.database.query(
    SupabaseQuery.new()
    .from('level test 2')
    .insert(
    [
      {
        "creatorId": user.id,
        "levelData": Marshalls.raw_to_base64(level.levelData),
        "levelImage": Marshalls.raw_to_base64(level.levelImage.save_png_to_buffer()),
        "levelName": level.levelName,
        "description": level.description,
        "creatorName": level.creatorName,
        "gameVersion": level.gameVersion,
        "levelVersion": level.levelVersion
      }
    ]
  )).completed

static func doesLevelExist(level: Level) -> Array:
  if not user: await LevelServer.requestLogin()
  var data = await LevelServer.query(
    SupabaseQuery.new()
    .from('level test 2')
    .eq("levelName", level.levelName)
    .eq("creatorId", str(user.id))
    .select(['id,levelVersion'])
  )
  # log.err(level.levelName, data)
  return data.map(func(e):
    return Level.new(
      level.levelName,
      e.id,
      '',
      level.creatorId,
      "",
      - 1,
      e.levelVersion,
    )
    )

static func loadAllLevels() -> Array:
  var data = await LevelServer.query(
    SupabaseQuery.new()
    .from('level test 2')
    .select(['id,creatorId,creatorName,gameVersion,levelVersion,levelName,description,levelImage'])
  )
  if not data:
    return []
  return data.map(func(e):
    var img := Image.new()
    img.load_png_from_buffer(Marshalls.base64_to_raw(e.levelImage))
    return Level.new(
      e.levelName,
      e.id,
      e.description,
      e.creatorId,
      e.creatorName,
      e.gameVersion,
      e.levelVersion,
      [],
      img
    )
    )
static func loadOldVersions(level: Level) -> Array:
  var data = (await Supabase.database.query(

    SupabaseQuery.new()
    .from('level test 2')

    .eq("creatorId", str(level.creatorId))
    .eq("levelName", level.levelName)
    .select(['id,creatorId,creatorName,gameVersion,levelVersion,levelName,description,levelImage'])
  ).completed).data
  return data.map(func(e):
    var img := Image.new()
    img.load_png_from_buffer(Marshalls.base64_to_raw(e.levelImage))
    return Level.new(
      e.levelName,
      e.id,
      e.description,
      e.creatorId,
      e.creatorName,
      e.gameVersion,
      e.levelVersion,
      [],
      img
    )
    )

static func downloadMap(level: LevelServer.Level):
  var id: int = level.onlineId
  var data = (await Supabase.database.query(
    SupabaseQuery.new()
    .from('level test 2')
    .eq("id", str(id)).select(["levelData"])).completed).data
  if !len(data):
    ToastParty.error("Download failed, the map " + level.levelName + " by " + level.creatorName + " doesn't exist, or the map doesn't exist.")
    return
  data = data[0]
  # log.pp(data)
  var f = FileAccess.open(global.path.abs("res://downloaded maps/" + level.levelName + '.vex++'), FileAccess.WRITE)
  var buff = Marshalls.base64_to_raw(data.levelData)
  f.store_buffer(buff)
  f.close()
  if await global.tryAndGetMapZipsFromArr([global.path.abs("res://downloaded maps/" + level.levelName + '.vex++')]):
    ToastParty.success("Download complete\nthe map " + level.levelName + " by " + level.creatorName + " has been loaded.")
  else:
    ToastParty.error("Download failed, the map " + level.levelName + " by " + level.creatorName + " doesn't exist, or the map was invalid.")

  # var allData := {}
  # for level in data:
  #   var gameVersion = int(data.gameVersion)
  #   var creatorName = data.creatorName
  #   var levelVersion = data.levelVersion
  #   var levelData = data.levelData
  #   var levelname = data.levelName
  #   if gameVersion not in allData:
  #     allData[gameVersion] = {}
  #   if creatorName not in allData[gameVersion]:
  #     allData[gameVersion][creatorName] = []
  #   allData[gameVersion][creatorName].append(levelname)

# func upload_file(file_path: String, base64_content: String, offlineLevelData: Dictionary) -> void:
#   var cleanup = func():
#     $AnimatedSprite2D.visible = false
#     DirAccess.remove_absolute("user://tempLevelOptions.sds")
#     DirAccess.remove_absolute("user://tempLevel.zip")
#   $AnimatedSprite2D.visible = true
#   $AnimatedSprite2D.frame = 0
#   var url = "https://api.github.com/repos/rsa17826/" + global.REPO_NAME + "/contents/" + global.urlEncode(file_path)
#   log.pp("Request URL: ", url)
#   var headers: PackedStringArray = [
#     "Authorization: token %s" % GITHUB_TOKEN,
#     "Content-Type: application/vnd.github.v3+json"
#   ]

#   var body = {
#     "message": "Add new file",
#     "content": base64_content,
#     "branch": global.BRANCH
#   }
#   ToastParty.info("Checking if level exists on server...")
#   var getRes = (await global.httpGet(url + "?rand=" + str(randf()), headers, HTTPClient.METHOD_GET)).response
#   # log.pp('getRes', getRes)
#   if "sha" in getRes:
#     DirAccess.remove_absolute("user://tempLevelOptions.sds")
#     DirAccess.remove_absolute("user://tempLevel.zip")
#     await global.httpGet("https://raw.githubusercontent.com/rsa17826/" +
#       global.REPO_NAME + "/main/" +
#       global.urlEncode(file_path) + "?rand=" + str(randf()),
#       PackedStringArray(),
#       HTTPClient.METHOD_GET,
#       '',
#       "user://tempLevel.zip",
#       false
#     )
#     var versionCheckPassed = false
#     var reader = ZIPReader.new()
#     var err = reader.open("user://tempLevel.zip")
#     var onlineLevelData = {"levelVersion": - 1}
#     if err:
#       log.warn("failed to download level data")
#       await global.wait(1000)
#     else:
#       reader.get_files()
#       var file = FileAccess.open("user://tempLevelOptions.sds", FileAccess.WRITE)
#       var buffer := reader.read_file("options.sds", false)
#       file.store_buffer(buffer)
#       file.close()
#       onlineLevelData = sds.loadDataFromFile("user://tempLevelOptions.sds")
#       log.pp(onlineLevelData, offlineLevelData, onlineLevelData.levelVersion < offlineLevelData.levelVersion, onlineLevelData.levelVersion, offlineLevelData.levelVersion)
#       if "levelVersion" not in onlineLevelData:
#         onlineLevelData.levelVersion = -1
#       if onlineLevelData.levelVersion < offlineLevelData.levelVersion:
#         versionCheckPassed = true
#       if not versionCheckPassed:
#         global.prompt(
#           "this level you are trying to upload is not newer than the version already uploaded" +
#           "\n\n ONLINE LEVEL VERSION: " + str(onlineLevelData.levelVersion) +
#           ' - LOCAL LEVEL VERSION: ' + str(offlineLevelData.levelVersion),
#           global.PromptTypes.info
#         )
#         cleanup.call()
#         return
#     if offlineLevelData.author and await global.prompt(
#       "there is already a level you have previously uploaded with that name. Do you want to overwrite it?\n" +
#       "if so, enter your creator name here: " + offlineLevelData.author +
#       "\n\n ONLINE LEVEL VERSION: " + str(onlineLevelData.levelVersion) +
#       ' - LOCAL LEVEL VERSION: ' + str(offlineLevelData.levelVersion),
#       global.PromptTypes.string
#     ) != offlineLevelData.author:
#       cleanup.call()
#       return
#     body.sha = getRes.sha

#   ToastParty.info("File upload started!")
#   var putRes = await global.httpGet(url, headers, HTTPClient.METHOD_PUT, JSON.stringify(body))

#   if putRes.code == 200 or putRes.code == 201:
#     ToastParty.success("File upload was successful!")
#   else:
#     log.err(putRes.code)
#     log.err(putRes.response)
#     log.err(headers)
#     ToastParty.error("File upload failed with error code: " + str(putRes.code))
#   cleanup.call()