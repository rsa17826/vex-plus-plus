extends CenterContainer

@export var uname: Control
@export var password: Control
@export var stayLoggedIn: CheckBox

func _on_register_pressed() -> void:
  var res = await LevelServer.register(uname.text, password.text)
  log.pp(res)
  if res:
    ToastParty.info(res)
  else:
    log.err("error", "failed to register")

func _on_login_pressed() -> void:
  var user = await LevelServer.login(uname.text, password.text)
  if user and stayLoggedIn.button_pressed:
    global.file.write("user://auth", user.refresh_token, false)