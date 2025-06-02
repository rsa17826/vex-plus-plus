extends Control

# @name same line return
# @regex :\s*return(\s*.{0,10})$
# @replace : return$1
# @flags gm
# @endregex

var __menu
@onready var pm: PopupMenu = PopupMenu.new()
func _ready() -> void:
  add_child(pm)
  var levelContainer = $MarginContainer/ScrollContainer/HFlowContainer
  const levelNode = preload("res://scenes/main menu/lvl_sel_item.tscn")
  Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
  var dir := DirAccess.open(global.path.parsePath("res://maps"))
  for level: String in dir.get_directories():
    var node := levelNode.instantiate()
    node.levelname.text = level
    var data = global.loadMapInfo(level)
    node.creator.text = ("Author: " + data.author) if data else "INVALID LEVEL"
    node.description.text = data.description if data else "INVALID LEVEL"
    if data:
      node.newSaveBtn.connect("pressed", loadLevel.bind(level, false))
      node.loadSaveBtn.connect("pressed", loadLevel.bind(level, true))
    node.moreOptsBtn.connect("pressed", showMoreOptions.bind(level))
    levelContainer.add_child(node)
  loadUserOptions()
  %version.text = "VERSION: " + str(global.VERSION)

func showMoreOptions(level):
  pm.system_menu_id = NativeMenu.SystemMenus.DOCK_MENU_ID
  var i = 0
  pm.clear()
  for k: String in ["duplicate", "delete", "rename", "share", "upload"]:
    pm.add_item(k, i)
    i += 1
  pm.add_item('< cancel >', i)
  var promise = Promise.new()
  pm.connect("index_pressed", promise.resolve)
  pm.popup.call_deferred(Rect2i(get_screen_transform() * get_local_mouse_position(), Vector2i.ZERO))
  var res = await promise.wait()
  log.pp(res)
  match res:
    0:
      global.copyDir(
        global.path.abs("res://maps/" + level),
        global.path.abs("res://maps/" + level + " (copy)")
      )
    1:
      OS.move_to_trash((global.path.abs("res://maps/" + level)))
    2:
      DirAccess.rename_absolute(
        global.path.abs("res://maps/" + level),
          global.path.abs(
            global.path.join("res://maps/",
              await global.prompt(
                "Rename map",
                global.PromptTypes.string,
                level
              )
            )
          )
        )
    3:
      log.pp(level)
      global.zipDir(
        global.path.abs("res://maps/" + level),
        global.path.abs("res://exports/" + level + ".vex++")
      )
      global.openPathInExplorer("res://exports")
    4:
      var outpath = global.path.abs("res://exports/" + level + ".vex++")
      global.zipDir(
        global.path.abs("res://maps/" + level),
        outpath
      )
      var f = FileAccess.open(outpath, FileAccess.READ)
      var data = sds.loadDataFromFile(global.path.abs("res://maps/" + level + "/options.sds"))

      var version = str(data.version)
      var author = data.author
      # var c = 'test'
      var c = Marshalls.raw_to_base64(f.get_buffer(f.get_length()))

      await upload_file("levels/" + version + '/' + author + '/' + level + ".vex++", c)
      f.close()
  # get_tree().reload_current_scene()
func url_encode(input: String) -> String:
  var encoded = ""
  for c in input:
    if c in 'qwertyuiopasdfghjklZxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM123789456/':
      encoded += c
    else:
      encoded += "%" + String("%02X" % (c).unicode_at(0))
  return encoded
const GITHUB_TOKEN = "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"
const BRANCH = "main"
func httpGet(url: String, custom_headers: PackedStringArray = PackedStringArray(), method: int = 0, request_data: String = ""):
  var http_request = HTTPRequest.new()
  var promise = Promise.new()
  add_child(http_request)
  http_request.request_completed.connect(func(result, response_code, headers, body):
    log.pp("DKLKLSADKLSDAKLKSADL", result, response_code, headers, body)
    var json := JSON.new()
    # var res=json.parse(body.get_string_from_utf8())
    var response=json.get_data()
    # log.pp(res, response, body.get_string_from_utf8())
    promise.resolve({"response": response, "code": response_code})
  )

  var error = http_request.request(url, custom_headers, method, request_data)
  if error != OK:
    push_error("An error occurred in the HTTP request.")
  return await promise.wait()
func upload_file(file_path: String, base64_content: String) -> void:
  var url = "https://api.github.com/repos/rsa17826/testing/contents/" + url_encode(file_path)
  log.pp("Request URL: ", url)

  var headers: PackedStringArray = [
    "Authorization: token %s" % GITHUB_TOKEN,
    "Content-Type: application/vnd.github.v3+json"
  ]

  var body = {
    "message": "Add new file",
    "content": base64_content,
    "branch": BRANCH
  }

  var json_body = JSON.stringify(body)
  log.pp("Request Body: ", json_body)

  var res = await httpGet(url, headers, HTTPClient.METHOD_PUT, json_body)

  if res.code == 200 or res.code == 201:
    log.pp("File uploade started successfully!")
  elif res.code == 422:
    log.pp("level already exists")
  else:
    log.pp(res.code)
    log.pp(res.response)
  
func loadLevel(level, fromSave) -> void:
  global.hitboxesShown = global.useropts.showHitboxes
  get_tree().set_debug_collisions_hint(global.hitboxesShown)
  global.loadMap(level, fromSave)

func loadUserOptions() -> void:
  var data = global.file.read("res://scenes/main menu/userOptsMenu.jsonc")
  __menu = Menu.new($ScrollContainer/VBoxContainer)
  for thing in data:
    match thing["thing"]:
      "option":
        __loadOptions(thing)
        break
      "group":
        for a in thing.value:
          __loadOptions(a)
  __menu.show_menu()
  __menu.onchanged.connect(updateUserOpts)

  updateUserOpts()

func updateUserOpts() -> void:
  var shouldChangeFsState = false
  var lastWinMode
  if 'windowMode' not in global.useropts:
    shouldChangeFsState = true
  else:
    lastWinMode = global.useropts.windowMode
  global.useropts = __menu.get_all_data()
  if lastWinMode == null or lastWinMode != global.useropts.windowMode:
    shouldChangeFsState = true
  if shouldChangeFsState:
    await global.wait(150)
    get_window().size = Vector2(1152, 648)
    match int(global.useropts.windowMode):
      0:
        global.fullscreen(1)
      1:
        global.fullscreen(-1)

  sds.prettyPrint = !global.useropts.smallerSaveFiles

func __loadOptions(thing) -> void:
  match thing["type"]:
    "bool":
      __menu.add_bool(thing["key"], thing["defaultValue"])
    "range":
      __menu.add_range(
        thing["key"],
        thing['min'],
        thing['max'],
        thing['step'] if "step" in thing else 1,
        thing["defaultValue"],
        thing['allow lesser'] if "allow lesser" in thing else false,
        thing['allow greater'] if "allow greater" in thing else false
      )
    "multi select":
      __menu.add_multi_select(
        thing["key"],
        thing['options'],
        thing["defaultValue"]
      )
    "single select":
      __menu.add_single_select(
        thing["key"],
        thing['options'],
        thing["defaultValue"]
      )
    "spinbox":
      __menu.add_spinbox(
        thing["key"],
        thing['min'],
        thing['max'],
        thing['step'] if "step" in thing else 1,
        thing["defaultValue"],
        thing['allow lesser'] if "allow lesser" in thing else false,
        thing['allow greater'] if "allow greater" in thing else false
      )

func _on_new_level_btn_pressed() -> void:
  var level = await global.createNewMapFolder()
  if not level: return
  global.useropts = __menu.get_all_data()
  loadLevel(level, false)

func _on_open_level_folder_pressed() -> void:
  global.openPathInExplorer("res://maps")

func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
  log.pp(response_code)
