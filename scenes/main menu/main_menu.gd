extends Control

# @name same line return
# @regex :\s*return(\s*.{0,10})$
# @replace : return$1
# @flags gm
# @endregex

var __menu

@export var CreateNewLevelButton: Button

func _ready() -> void:
  Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
  log.pp(global.path.parsePath("res://levelcodes"))
  var dir := DirAccess.open(global.path.parsePath("res://levelcodes"))
  for level: String in dir.get_directories():
    var node := %lvlSelItem.duplicate()
    node.get_node("VBoxContainer/Label").text = level
    var data = global.loadLevelPackInfo(level)
    node.get_node("VBoxContainer/Label2").text = "Author: " + data.author
    node.get_node("VBoxContainer/Label3").text = data.description
    node.get_node('VBoxContainer/Button').connect("pressed", loadLevel.bind(level, false))
    node.get_node('VBoxContainer/Button2').connect("pressed", loadLevel.bind(level, true))
    $MarginContainer/ScrollContainer/HFlowContainer.add_child(node)
  %lvlSelItem.queue_free.call_deferred()
  loadUserOptions()
  %version.text = "VERSION: " + str(global.VERSION)

func loadLevel(level, fromSave) -> void:
  global.loadLevelPack(level, fromSave)

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
  if lastWinMode != global.useropts.windowMode:
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
  global.loadLevelPack(level, false)

func _on_open_level_folder_pressed() -> void:
  OS.create_process("explorer", PackedStringArray([
    '"' + (
      ProjectSettings.globalize_path("res://levelcodes")
      if OS.has_feature("editor") else
      global.path.parsePath("res://levelcodes")
    ).replace("/", "\\")
    + '"'
  ]))
