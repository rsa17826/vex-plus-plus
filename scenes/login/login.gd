extends CenterContainer

@export var uname: Control
@export var password: Control
@export var password2: Control
@export var stayLoggedIn: CheckBox

func _on_register_pressed() -> void:
  if password2.text and password2.text != password.text:
    ToastParty.err("passwords do not match")
    return
  var res = await LevelServer.register(uname.text, password.text)
  if res:
    log.pp("user id: res.id")
    ToastParty.info('successfully registered with id: ' + res.id)
  else:
    log.err("error", "failed to register")

func _on_login_pressed() -> void:
  if password2.text and password2.text != password.text:
    ToastParty.err("passwords do not match")
    return
  var user = await LevelServer.login(uname.text, password.text)
  if user and stayLoggedIn.button_pressed:
    global.file.write("user://auth", user.refresh_token, false)

func _on_logout_pressed() -> void:
  DirAccess.remove_absolute(global.path.abs("user://auth"))
  Supabase.auth.sign_out()
  LevelServer.user = null
  ToastParty.info("logged out")