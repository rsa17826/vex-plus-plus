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
  # dir.list_dir_begin()
  $MarginContainer.size = global.windowSize
  $MarginContainer.position.y = (global.windowSize.y / 2.0) - 50
  $HFlowContainer.position.y = (global.windowSize.y / 2.0) - 100
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

func loadLevel(level, fromSave) -> void:
  global.useropts = __menu.get_all_data()
  # log.pp(global.useropts)
  global.loadLevelPack(level, fromSave)

func loadUserOptions() -> void:
  var data = global.file.read("res://scenes/main menu/userOptsMenu.jsonc")
  var OBJECT = typeof({})
  __menu = Menu.new($VBoxContainer)
  for thing in data:
    match typeof(thing):
      OBJECT:
        # log.pp(thing)
        match thing["thing"]:
          "option":
            __loadOptions(thing)
            break
          "group":
            for a in thing.value:
              __loadOptions(a)
      _:
        log.err("invalid data type", thing, data)
  __menu.show_menu()

func __loadOptions(thing) -> void:
  match thing["type"]:
    "bool":
      __menu.add_bool(thing["key"], thing["defaultValue"])
    "int":
      __menu.add_range(
        thing["key"],
        thing['min'],
        thing['max'],
        thing['step'] if "step" in thing else 1,
        thing["defaultValue"],
        thing['allow lesser'] if "allow lesser" in thing else false,
        thing['allow greater'] if "allow greater" in thing else false
      )
    "float":
      __menu.add_float(thing["key"], thing["defaultValue"])

func _on_new_level_btn_pressed() -> void:
  var level = await global.createNewMapFolder()
  if not level: return
  global.useropts = __menu.get_all_data()
  global.loadLevelPack(level, false)
