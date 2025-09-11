extends Control
class_name LevelServer
# var _name := ''
# var _password := ''
# var _channel

# func upload_file(filePath: String, id) -> void:
#   var f = FileAccess.open(filePath, FileAccess.READ)
#   var c = Marshalls.raw_to_base64(f.get_buffer(f.get_length()))
#   # return await Talo.channels.update(id, '', -1, {filePath: c})
#   await Talo.channels.set_storage_props(id, {"level": c})

# func createChannel(name: String, data: Dictionary[String, String]={}) -> TaloChannel:
#   var options := Talo.channels.CreateChannelOptions.new()
#   options.name = name
#   options.auto_cleanup = false
#   data.ownerId = str(Talo.current_alias.id)
#   data.username = name
#   options.props = (data as Dictionary[String, String])
#   var channel := await Talo.channels.create(options)

#   log.pp(channel.name) # channel name
#   log.pp(channel.props) # [{ "prop_key": "prop_value" }]
#   return channel

# func getAllChannels(page: int = 0) -> ChannelsAPI.ChannelPage:
#   var res := await Talo.channels.get_channels(Talo.channels.GetChannelsOptions.new())
#   log.pp(res)
#   return res

# func _ready() -> void:
#   Talo.player_auth.session_not_found.connect(on_session_not_found, Object.CONNECT_ONE_SHOT)
#   Talo.player_auth.session_found.connect(on_session_found, Object.CONNECT_ONE_SHOT)
#   Talo.players.identified.connect(on_identified)
#   disable()
#   Talo.player_auth.start_session()

# func enable():
#   %login.disabled = false
#   %register.disabled = false
#   %"delete account".disabled = false

# func disable():
#   %login.disabled = true
#   %register.disabled = true
#   %"delete account".disabled = true

# func on_session_not_found():
#   enable()

# func getOwnChannel() -> TaloChannel:
#   var options := Talo.channels.GetChannelsOptions.new()
#   options.page = 0
#   options.prop_key = "ownerId"
#   options.prop_value = str(Talo.current_alias.id)
#   var res := await Talo.channels.get_channels(options)
#   breakpoint
#   if res.count == 0:
#     return await createChannel(Talo.player_auth.session_manager.get_identifier())
#   log.pp(res)
#   return res.channels[0]

# func register(name: String, password: String) -> bool:
#   var err := await Talo.player_auth.register(name, password)
#   if err:
#     log.err(err, "register failed")
#     match Talo.player_auth.last_error.get_code():
#       TaloAuthError.ErrorCode.IDENTIFIER_TAKEN:
#         log.err('register', "Username is already taken")
#       _:
#         log.warn('register', Talo.player_auth.last_error.get_string())
#     return false
#   return true

# func login(name: String, password: String) -> bool:
#   _name = name
#   _password = password
#   var res := await Talo.player_auth.login(name, password)
#   match res:
#     Talo.player_auth.LoginResult.FAILED:
#       match Talo.player_auth.last_error.get_code():
#         TaloAuthError.ErrorCode.INVALID_CREDENTIALS:
#           log.err('login', "Username or password is incorrect")
#         _:
#           log.err('login', Talo.player_auth.last_error.get_string())
#     Talo.player_auth.LoginResult.VERIFICATION_REQUIRED:
#       log.err('login', "Verification required")
#     Talo.player_auth.LoginResult.OK: return true
#   return false

# func on_session_found():
#   _name = Talo.player_auth.session_manager.get_identifier()
#   %Username.text = _name
#   if Talo.current_alias:
#     _channel = await getOwnChannel()

# func _on_login_pressed() -> void:
#   disable()
#   if await login(%Username.text, %Password.text):
#     _channel = await getOwnChannel()
#   enable()

# func _on_register_pressed() -> void:
#   disable()
#   if await register(%Username.text, %Password.text):
#     _channel = await getOwnChannel()
#   enable()

# func on_identified(user: TaloPlayer):
#   log.pp(user, Talo.player_auth.session_manager.get_identifier())
#   log.pp("login successful!!")
#   enable()

# func _on_delete_account_pressed() -> void:
#   disable()
#   await Talo.player_auth.delete_account(%Password.text)
#   enable()

# func _on_delete_account_2_pressed() -> void:
#   if !_channel:
#     _channel = await getOwnChannel()
#   await upload_file(r"D:\Games\vex++\game data\exports\moving things.vex++", _channel.id)

# func _on_delete_account_3_pressed() -> void:
#   var channels = (await getAllChannels()).channels
#   for channel in channels:
#     var data = await Talo.channels.get_storage_prop(channel.id, "level", true)
#     if !data:
#       log.err("no data", channel.id, channel.name)
#       continue
#     log.pp(data.key, data.value)

# --> PUT https://api.trytalo.com/v1/game-channels/2036/storage [200] { "channel": { "id": 2036.0, "name": "z", "owner": { "id": 34638.0, "service": "talo", "identifier": "z", "player": { "id": "22d8456e-c223-44b2-8422-0e48a1cdbacc", "props": [{ "key": "META_DEV_BUILD", "value": "1" }], "devBuild": true, "createdAt": "2025-08-18T18:39:54.000Z", "lastSeenAt": "2025-08-18T18:52:50.000Z", "groups": [], "auth": { "email": <null>, "verificationEnabled": false, "sessionCreatedAt": "2025-08-18T18:52:50.000Z" }, "presence": { "online": true, "customStatus": "", "updatedAt": "2025-08-18T18:52:50.000Z" } }, "lastSeenAt": "2025-08-18T18:52:41.000Z", "createdAt": "2025-08-18T18:39:54.000Z", "updatedAt": "2025-08-18T18:52:41.000Z" }, "totalMessages": 0.0, "props": [{ "key": "ownerId", "value": "34638" }, { "key": "username", "value": "z" }], "autoCleanup": false, "private": false, "temporaryMembership": false, "createdAt": "2025-08-18T18:51:03.000Z", "updatedAt": "2025-08-18T18:51:03.000Z" }, "upsertedProps": [], "deletedProps": [], "failedProps": [{ "key": "level", "error": "Prop value length (2316) exceeds 512 characters" }] }

# func _on_button_pressed() -> void:
#   # await Talo.players.identify('username', 'ass')
#   # log.pp(await register("testuser", 'testpass'))
#   log.pp(await login("testuser", 'testpass'))
#   Talo.player_auth.start_session()
#   var channel := await getOwnChannel()
#   upload_file(r"D:\Games\vex++\game data\exports\moving things.vex++", channel.id)
#   var channels = await getAllChannels()
#   log.err(channels.channels, channel.owner_alias.id, Talo.current_alias.id)
#   # if Talo.current_alias.id != channel.owner.id: return

#   # await Talo.channels.set_storage_props(channel.id, {
#   #   'prop1': "value1",
#   #   'prop2': "value2"
#   # })
  # if Talo.current_alias.id != channel.owner.id: return

  # await Talo.channels.set_storage_props(channel.id, {
  #   prop1: "value1",
  #   prop2: "value2"
  # })
  # Talo.channels.set_storage_props(id, {
  #   'prop1': "value1",
  #   'prop2': "value2"
  # })
  # await Talo.channels.update(id, '', -1, {'prop1': "value1",
  #   'prop2': "value2"})
  # breakpoint
  # upload_file(r"D:\Games\vex++\game data\exports\moving things.vex++")
  # var name = "Save %s version 1" % [TaloTimeUtils.get_current_datetime_string()]
  # # var res := await Talo.player_auth.login(username.text, password.text)
  # # match res:
  # #   Talo.player_auth.LoginResult.FAILED:
  # #     match Talo.player_auth.last_error.get_code():
  # #       TaloAuthError.ErrorCode.INVALID_CREDENTIALS:
  # #         validation_label.text = "Username or password is incorrect"
  # #       _:
  # #         validation_label.text = Talo.player_auth.last_error.get_string()
  # #   Talo.player_auth.LoginResult.VERIFICATION_REQUIRED:
  # #     verification_required.emit()
  # #   Talo.player_auth.LoginResult.OK: pass
  # var score := randf()
  # var options := Talo.channels.GetChannelsOptions.new()
  # options.page = 0
  # var res := await Talo.channels.get_channels(options)

  # var channels: Array[TaloChannel] = res.channels
  # var ccc = channels[0]
  # Talo.channels.update(ccc.id, '', -1, {
  #   "data": c
  # })
  # # var count: int = res.count
  # # var is_last_page: bool = res.is_last_page
  # log.pp(ccc, ccc.props)
  # var res2 = await Talo.saves.create_save(name, {'data': c})
  # var saves := await Talo.saves.get_saves()
  # log.pp(saves)
  # log.err(Talo.saves.latest, Talo.saves.latest.to_dictionary().content.data)
  # var res2 := await Talo.leaderboards.add_entry(leaderboard_name, 1, {'data': c})
  # log.pp(res2)
  # log.pp("Added score: %s, at position: %s, new high score: %s" % [score, res2.entry.position, "yes" if res2.updated else "no"])

# func _on_button_pressed() -> void:
#   var res = await Talo.player_auth.register(username.text, password.text, email.text, enable_verification.button_pressed)
#   if res != OK:
#     match Talo.player_auth.last_error.get_code():
#       TaloAuthError.ErrorCode.IDENTIFIER_TAKEN:
#         validation_label.text = "Username is already taken"
#       _:
#         validation_label.text = Talo.player_auth.last_error.get_string()

# # @onready var username: TextEdit = %Username
# # @onready var password: TextEdit = %Password
# # @onready var validation_label: Label = %ValidationLabel

# # ...

# # var res := await Talo.player_auth.login(username.text, password.text)
# # match res:
# #   Talo.player_auth.LoginResult.FAILED:
# #     match Talo.player_auth.last_error.get_code():
# #       TaloAuthError.ErrorCode.INVALID_CREDENTIALS:
# #         validation_label.text = "Username or password is incorrect"
# #       _:
# #         validation_label.text = Talo.player_auth.last_error.get_string()
# #   Talo.player_auth.LoginResult.VERIFICATION_REQUIRED:
# #     verification_required.emit()
# #   Talo.player_auth.LoginResult.OK:
# #     pass

# # extends Button

# @export var leaderboard_name: String = 'test'
# var current_page: int = 0

# func _on_button_pressed() -> void:
#   var options := Talo.leaderboards.GetEntriesOptions.new()
#   options.page = current_page

#   var res := await Talo.leaderboards.get_entries(leaderboard_name, options)
#   var entries: Array[TaloLeaderboardEntry] = res.entries
#   var count: int = res.count
#   var is_last_page: bool = res.is_last_page

#   log.pp("%s entries, is last page: %s" % [count, is_last_page])

# # var options := Talo.leaderboards.GetEntriesOptions.new()
# # options.page = page

# # var res := await Talo.leaderboards.get_entries_for_current_player(internal_name, options)

static var user: SupabaseUser = null

static func login(uname: String, password: String) -> SupabaseUser:
  var authTask: AuthTask = await Supabase.auth.sign_in(
    uname,
    password
  ).completed
  if authTask.user:
    log.pp("logged in")
  else:
    log.pp("failed to login")
  user = authTask.user
  return authTask.user

func _ready():
  var user = await login("test", "1234")
  log.pp(user)
  log.pp(await getData())

static func getData(data:=["*"]):
  return (await Supabase.database.query(SupabaseQuery.new('level test 2').select(data)).completed).data

class Level:
  var levelName: String = ""
  var description: String = ""
  var creatorId: String = ""
  var creatorName: String = ""
  var gameVersion: int
  var onlineId: int
  var levelVersion: int
  var levelData: PackedByteArray
  func _init(
    _levelName: String = '',
    _onlineId: int = -1,
    _description: String = '',
    _creatorId: String = '',
    _creatorName: String = '',
    _gameVersion: int = -1,
    _levelVersion: int = -1,
    _levelData: PackedByteArray = []
  ):
    self.levelName = _levelName
    self.description = _description if _description else "NO DESCRIPTION SET"
    self.onlineId = _onlineId
    self.creatorId = _creatorId
    self.creatorName = _creatorName
    self.gameVersion = _gameVersion
    self.levelVersion = _levelVersion
    self.levelData = _levelData

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

static func uploadLevel(level: Level):
  if not user:
    await LevelServer.login(
      await global.prompt("Please enter your username: ", global.PromptTypes.string),
      await global.prompt("Please enter your password: ", global.PromptTypes.string)
    )
  return await Supabase.database.query(SupabaseQuery.new('level test 2').insert(
    [
      {
        "user_id": user.id,
        "levelData": Marshalls.raw_to_base64(level.levelData),
        "levelName": level.levelName,
        # "description": level.description,
        "creatorName": level.creatorName,
        "gameVersion": level.gameVersion,
        "levelVersion": level.levelVersion
      }
    ]
  )).completed

static func loadAllLevels() -> Array[Level]:
  var data = await LevelServer.getData(['id,user_id,creatorName,gameVersion,levelVersion'])
  return data.map(func(e):
    return Level.new(
      e.levelName,
      e.id,
      '',
      e.user_id,
      e.creatorName,
      e.gameVersion,
      e.levelVersion,
    )
    )
static func loadOldVersions(level: Level) -> Array[Level]:
  var data = (await Supabase.database.query(
    SupabaseQuery.new('level test 2')
    .eq("user_id", str(level.creatorId))
    .eq("levelName", level.levelName)
    .select(['id,user_id,creatorName,gameVersion,levelVersion'])
  ).completed).data
  return data.map(func(e):
    return Level.new(
      e.levelName,
      e.id,
      '',
      e.user_id,
      e.creatorName,
      e.gameVersion,
      e.levelVersion,
    )
    )

static func downloadMap(level: LevelServer.Level):
  var id: int = level.onlineId
  var data = (await Supabase.database.query(SupabaseQuery.new('level test 2').eq("id", str(id)).select(["levelData"])).completed).data
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