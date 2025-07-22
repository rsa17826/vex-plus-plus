extends Control

var GITHUB_TOKEN = global.getToken()
const BRANCH = "main"
const REPO_NAME = "vex-plus-plus-level-codes"

@export var optsmenunode: Control
@export var levelContainer: Control
@export var scrollContainer: ScrollContainer

var __menu
@onready var pm: PopupMenu = PopupMenu.new()
func _ready() -> void:
  add_child(pm)
  const levelNode = preload("res://scenes/main menu/lvl_sel_item.tscn")
  Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
  var dir := DirAccess.open(global.MAP_FOLDER)
  var dirs = (dir.get_directories() as Array)
  dirs.sort_custom(func(a, s):
    return global.loadMapInfo(a).version > global.loadMapInfo(s).version
  )
  for level: String in dirs:
    var node := levelNode.instantiate()
    node.levelname.text = level
    var data = global.loadMapInfo(level)
    var versiontext = "V" + str(data.version) + " "
    if data.version > global.VERSION:
      versiontext += ">"
    elif data.version < global.VERSION:
      versiontext += "<"
    else:
      versiontext += "="
    node.version.text = versiontext
    node.creator.text = ("Author: " + data.author) if data else "INVALID LEVEL"
    node.description.text = data.description if data else "INVALID LEVEL"
    if data:
      node.newSaveBtn.connect("pressed", loadLevel.bind(level, false))
      node.loadSaveBtn.connect("pressed", loadLevel.bind(level, true))
      node.tooltip_text = data.description if data.description else "NO DESCRIPTION SET"
      node.newSaveBtn.tooltip_text = node.tooltip_text
      node.loadSaveBtn.tooltip_text = node.tooltip_text
    node.moreOptsBtn.connect("pressed", showMoreOptions.bind(level))
    levelContainer.add_child(node)
  loadUserOptions()
  %version.text = "VERSION: " + str(global.VERSION)
  # $CTRLS/VBoxContainer/InputMappingContainer/InputActionsTree._build_ui_tree()

func showMoreOptions(level):
  pm.system_menu_id = NativeMenu.SystemMenus.DOCK_MENU_ID
  var i := 0
  pm.clear()
  for k: String in [
    "duplicate",
    "delete",
    "rename",
    "show in file explorer",
    "open settings file",
    "export",
    "upload"
  ]:
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
        global.path.join(global.MAP_FOLDER, level),
        global.path.join(global.MAP_FOLDER, level + " (copy)")
      )
      get_tree().reload_current_scene()
    1:
      OS.move_to_trash((global.path.join(global.MAP_FOLDER, level)))
      get_tree().reload_current_scene()
    2:
      DirAccess.rename_absolute(
        global.path.join(global.MAP_FOLDER, level),
        global.path.join(global.MAP_FOLDER,
          (await global.prompt(
            "Rename map",
            global.PromptTypes.string,
            level
          )).replace("/", '').replace("\\", '')
        )
      )
      get_tree().reload_current_scene()
    3:
      OS.shell_open(global.path.join(global.MAP_FOLDER, level))
    4:
      OS.shell_open(global.path.join(global.MAP_FOLDER, level, "options.sds"))
    5:
      log.pp(level)
      global.zipDir(
        global.path.join(global.MAP_FOLDER, level),
        global.path.abs("res://exports/" + level + ".vex++")
      )
      OS.shell_open(global.path.abs("res://exports"))
    6:
      var outpath = global.path.abs("res://exports/" + level + ".vex++")
      global.zipDir(
        global.path.join(global.MAP_FOLDER, level),
        outpath
      )
      var f = FileAccess.open(outpath, FileAccess.READ)
      var data = sds.loadDataFromFile(global.path.join(global.MAP_FOLDER, level, "/options.sds"))

      var version = str(data.version)
      var author = data.author
      var c = Marshalls.raw_to_base64(f.get_buffer(f.get_length()))
      if not author:
        ToastParty.err("Please enter an author name")
        return
      if not level:
        ToastParty.err("Please enter a map name")
        return
      await upload_file("levels/" + version + '/' + author + '/' + level + ".vex++", c)
      f.close()

# https://api.github.com/repos/rsa17826/vex-plus-plus-level-codes/contents/

func upload_file(file_path: String, base64_content: String) -> void:
  var url = "https://api.github.com/repos/rsa17826/" + REPO_NAME + "/contents/" + global.urlEncode(file_path)
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
  # log.pp("Request Body: ", json_body)

  var res = await global.httpGet(url, headers, HTTPClient.METHOD_PUT, json_body)

  if res.code == 200 or res.code == 201:
    ToastParty.success("File upload was successful!")
  elif res.code == 422:
    ToastParty.error("ERROR 422")
    # OS.alert("level already exists")
  else:
    log.err(res.code)
    log.err(res.response)
    log.err(headers)
    ToastParty.error("ERROR: " + str(res.code))
  
func loadLevel(level, fromSave) -> void:
  global.hitboxesShown = global.useropts.showHitboxes
  get_tree().set_debug_collisions_hint(global.hitboxesShown)
  global.loadMap(level, fromSave)

func loadUserOptions() -> void:
  var data = global.file.read("res://scenes/main menu/userOptsMenu.jsonc")
  __menu = Menu.new(optsmenunode)
  for thing in data:
    match thing.thing:
      "option":
        __loadOptions(thing)
        break
      "group":
        __menu.startGroup(thing.name)
        # log.pp(thing.name, thing.value)
        for a in thing.value:
          __loadOptions(a)
        __menu.endGroup()
  __menu.show_menu()
  __menu.onchanged.connect(updateUserOpts)
  scrollContainer.set_deferred('scroll_vertical', int(global.file.read("user://scrollContainerscroll_vertical", false, "0")))
  scrollContainer.gui_input.connect(func(event):
    # scroll up or down then save scroll position
    if event.button_mask == 8 || event.button_mask == 16:
      global.file.write("user://scrollContainerscroll_vertical", str(scrollContainer.scroll_vertical), false))

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
  if 'editorOnly' in thing and thing.editorOnly and not OS.has_feature("editor"): return
  match thing.type:
    "bool":
      __menu.add_bool(thing.key, thing.defaultValue)
    "range":
      __menu.add_range(
        thing.key,
        thing.min,
        thing.max,
        thing.step if "step" in thing else 1,
        thing.defaultValue,
        thing['allow lesser'] if "allow lesser" in thing else false,
        thing['allow greater'] if "allow greater" in thing else false
      )
    "multi select":
      __menu.add_multi_select(
        thing.key,
        thing.options,
        thing.defaultValue
      )
    "single select":
      __menu.add_single_select(
        thing.key,
        thing.options,
        thing.defaultValue
      )
    "spinbox":
      __menu.add_spinbox(
        thing.key,
        thing.min,
        thing.max,
        thing.step if "step" in thing else 1,
        thing.defaultValue,
        thing['allow lesser'] if "allow lesser" in thing else false,
        thing['allow greater'] if "allow greater" in thing else false
      )
    "rgba":
      __menu.add_rgba(
        thing.key,
        thing.defaultValue,
      )
    "rgb":
      __menu.add_rgb(
        thing.key,
        thing.defaultValue,
      )

func _on_new_level_btn_pressed() -> void:
  var level = await global.createNewMapFolder()
  if not level: return
  global.useropts = __menu.get_all_data()
  loadLevel(level, false)

func _on_open_level_folder_pressed() -> void:
  OS.shell_open(global.path.abs(global.MAP_FOLDER))

func _on_load_online_levels_pressed() -> void:
  get_tree().change_scene_to_file("res://scenes/online level list/main.tscn")

func _on_open_readme_pressed() -> void:
  var p = "https://github.com/rsa17826/vex-plus-plus#vex"
  OS.shell_open(p)
