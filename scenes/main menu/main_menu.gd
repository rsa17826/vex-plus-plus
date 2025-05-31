extends Control

# @name same line return
# @regex :\s*return(\s*.{0,10})$
# @replace : return$1
# @flags gm
# @endregex

var __menu

func _ready() -> void:
  var levelContainer = $MarginContainer/ScrollContainer/HFlowContainer
  const levelNode = preload("res://scenes/main menu/lvl_sel_item.tscn")
  Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
  log.pp(global.path.parsePath("res://maps"))
  var dir := DirAccess.open(global.path.parsePath("res://maps"))
  for level: String in dir.get_directories():
    var node := levelNode.instantiate()
    node.levelname.text = level
    var data = global.loadMapInfo(level)
    node.creator.text = "Author: " + data.author
    node.description.text = data.description
    node.newSaveBtn.connect("pressed", loadLevel.bind(level, false))
    node.loadSaveBtn.connect("pressed", loadLevel.bind(level, true))
    node.moreOptsBtn.connect("pressed", showMoreOptions.bind(level))
    levelContainer.add_child(node)
  loadUserOptions()
  %version.text = "VERSION: " + str(global.VERSION)

func showMoreOptions(level):
  var res = await global.prompt("", global.PromptTypes.singleArr, null,
  ["duplicate", "delete", "rename", "share"])
  match res:
    "duplicate":
      global.duplicateMap(level)
    "delete":
      global.deleteMap(level)
    "rename":
      global.renameMap(level)
    "share":
      log.pp(level)
      global.zipDir(
        global.path.abs("res://maps/" + level),
        global.path.abs("res://exports/" + level + ".vex++")
      )
      global.openPathInExplorer("res://exports")

func loadLevel(level, fromSave) -> void:
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
  if not lastWinMode or lastWinMode != global.useropts.windowMode:
    shouldChangeFsState = true
  if shouldChangeFsState == true:
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
  global.loadMap(level, false)

func _on_open_level_folder_pressed() -> void:
  global.openPathInExplorer("res://maps")
