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
  var ok = await LevelServer.register(uname.text, password.text)
  if not ok:
    log.err("error", "failed to register")
  # stayLoggedIn has no separate meaning here: the identity is always saved
  # locally (encrypted with the password) so it can be reused on this device;
  # there's no server session token to persist.
  LevelServer.updateCurrentUserInfoNode()

func _on_login_pressed() -> void:
  LevelServer.updateCurrentUserInfoNode()
  if password2.text and password2.text != password.text:
    ToastParty.err("passwords do not match")
    return
  await LevelServer.login(uname.text, password.text)
  LevelServer.updateCurrentUserInfoNode()

func _on_logout_pressed() -> void:
  LevelServer.updateCurrentUserInfoNode()
  LevelServer.username = ""
  LevelServer.identityKey = null
  ToastParty.info("logged out")
  LevelServer.updateCurrentUserInfoNode()
