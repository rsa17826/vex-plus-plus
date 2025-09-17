extends CenterContainer

@export var uname: Control
@export var password: Control
@export var password2: Control
@export var stayLoggedIn: CheckBox

func _on_register_pressed() -> void:
  LevelServer.updateCurrentUserInfoNode()
  if password2.text and password2.text != password.text:
    ToastParty.err("passwords do not match")
    return
  var user = await LevelServer.register(uname.text, password.text)
  if user:
    log.pp("user id: " + user.id)
    ToastParty.info('successfully registered with id: ' + user.id)
    if stayLoggedIn.button_pressed:
      global.file.write("user://auth", user.refresh_token, false)
  else:
    log.err("error", "failed to register")
  LevelServer.updateCurrentUserInfoNode()

func _on_login_pressed() -> void:
  LevelServer.updateCurrentUserInfoNode()
  if password2.text and password2.text != password.text:
    ToastParty.err("passwords do not match")
    return
  var user = await LevelServer.login(uname.text, password.text)
  if user and stayLoggedIn.button_pressed:
    global.file.write("user://auth", user.refresh_token, false)
  LevelServer.updateCurrentUserInfoNode()

func _on_logout_pressed() -> void:
  LevelServer.updateCurrentUserInfoNode()
  DirAccess.remove_absolute(global.path.abs("user://auth"))
  await Supabase.auth.sign_out().completed
  LevelServer.user = null
  ToastParty.info("logged out")
  LevelServer.updateCurrentUserInfoNode()