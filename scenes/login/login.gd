extends Control

var _name := ''
var _password := ''

func upload_file(filePath: String, id) -> TaloChannel:
  var f = FileAccess.open(filePath, FileAccess.READ)
  var c = Marshalls.raw_to_base64(f.get_buffer(f.get_length()))
  return await Talo.channels.update(id, '', -1, {filePath: c})

func createChannel(name: String, data: Dictionary[String, String]={}) -> TaloChannel:
  var options := Talo.channels.CreateChannelOptions.new()
  options.name = name
  options.auto_cleanup = false
  data.ownerId = str(Talo.current_alias.id)
  data.username = name
  options.props = (data as Dictionary[String, String])
  var channel := await Talo.channels.create(options)

  log.pp(channel.name) # channel name
  log.pp(channel.props) # [{ "prop_key": "prop_value" }]
  return channel

func getAllChannels(page: int = 0) -> ChannelsAPI.ChannelPage:
  var res := await Talo.channels.get_channels(Talo.channels.GetChannelsOptions.new())
  log.pp(res)
  return res

func _ready() -> void:
  Talo.player_auth.session_not_found.connect(on_session_not_found, Object.CONNECT_ONE_SHOT)
  Talo.player_auth.session_found.connect(on_session_found, Object.CONNECT_ONE_SHOT)
  Talo.players.identified.connect(on_identified)
  disable()
  Talo.player_auth.start_session()

func enable():
  %login.disabled = false
  %register.disabled = false
  %"delete account".disabled = false

func disable():
  %login.disabled = true
  %register.disabled = true
  %"delete account".disabled = true

func on_session_not_found():
  enable()

func getOwnChannel() -> TaloChannel:
  var options := Talo.channels.GetChannelsOptions.new()
  options.page = 0
  options.prop_key = "ownerId"
  options.prop_value = str(Talo.current_alias.id)
  var res := await Talo.channels.get_channels(options)
  breakpoint
  if res.count == 0:
    return await createChannel(str(Talo.current_alias.id))
  log.pp(res)
  return res.channels[0]

func register(name: String, password: String) -> bool:
  var err := await Talo.player_auth.register(name, password)
  if err:
    log.err(err, "register failed")
    match Talo.player_auth.last_error.get_code():
      TaloAuthError.ErrorCode.IDENTIFIER_TAKEN:
        log.err('register', "Username is already taken")
      _:
        log.warn('register', Talo.player_auth.last_error.get_string())
    return false
  return true

func login(name: String, password: String) -> bool:
  _name = name
  _password = password
  var res := await Talo.player_auth.login(name, password)
  match res:
    Talo.player_auth.LoginResult.FAILED:
      match Talo.player_auth.last_error.get_code():
        TaloAuthError.ErrorCode.INVALID_CREDENTIALS:
          log.err('login', "Username or password is incorrect")
        _:
          log.err('login', Talo.player_auth.last_error.get_string())
    Talo.player_auth.LoginResult.VERIFICATION_REQUIRED:
      log.err('login', "Verification required")
    Talo.player_auth.LoginResult.OK: return true
  return false

func on_session_found():
  _name = Talo.player_auth.session_manager.get_identifier()
  %Username.text = _name

func _on_login_pressed() -> void:
  disable()
  log.pp(await login(%Username.text, %Password.text))
  enable()

func _on_register_pressed() -> void:
  disable()
  log.pp(await register(%Username.text, %Password.text))
  enable()

func on_identified(user: TaloPlayer):
  log.pp(user, Talo.player_auth.session_manager.get_identifier())
  log.pp("login successful!!")
  enable()

func _on_delete_account_pressed() -> void:
  disable()
  await Talo.player_auth.delete_account(%Password.text)
  enable()

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
