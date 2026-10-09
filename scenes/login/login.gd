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
  if ok:
    if stayLoggedIn.button_pressed:
      saveLogin()
    ToastParty.info('successfully registered as ' + LevelServer.username)
  else:
    log.err("error", "failed to register")
  LevelServer.updateCurrentUserInfoNode()

func _on_login_pressed() -> void:
  LevelServer.updateCurrentUserInfoNode()
  if password2.text and password2.text != password.text:
    ToastParty.err("passwords do not match")
    return
  if await LevelServer.login(uname.text, password.text):
    ToastParty.info('successfully logged in as ' + LevelServer.username)
    if stayLoggedIn.button_pressed:
      saveLogin()
  LevelServer.updateCurrentUserInfoNode()

func saveLogin():
  var f = FileAccess.open("user://auth", FileAccess.WRITE)
  if !f:
    log.err("failed to save login!")
  f.store_var(LevelServer.identityKey, true)
  f.store_var(LevelServer.username)

func _on_logout_pressed() -> void:
  LevelServer.updateCurrentUserInfoNode()
  LevelServer.username = ""
  LevelServer.identityKey = null
  ToastParty.info("logged out")
  LevelServer.updateCurrentUserInfoNode()

func _ready() -> void:
  if LevelServer.identityKey: return
  if "--disable-auto-login" in OS.get_cmdline_user_args(): return
  var f = FileAccess.open("user://auth", FileAccess.READ)
  if f:
    var temp = f.get_var(true)
    if temp:
      LevelServer.identityKey = temp
      temp = f.get_var()
      if temp:
        LevelServer.username = temp
        LevelServer.updateCurrentUserInfoNode()
      else:
        log.warn("failed to login - no username")
        DirAccess.remove_absolute("user://auth")
    else:
      log.warn("failed to login - no key")
      DirAccess.remove_absolute("user://auth")
  log.pp(LevelServer.identityKey, LevelServer.username, "LevelServer.identityKey")
