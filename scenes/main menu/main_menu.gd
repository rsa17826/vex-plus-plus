extends Control
var m
# @name same line return
# @regex :\s*return(\s*.{0,10})$
# @replace : return$1
# @flags gm
# @endregex

func _ready() -> void:
  Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
  log.pp(global.path.parsePath("res://levelcodes"))
  var dir := DirAccess.open(global.path.parsePath("res://levelcodes"))
  # dir.list_dir_begin()
  $ScrollContainer.size = DisplayServer.window_get_size()
  $ScrollContainer.position.y = (DisplayServer.window_get_size().y / 2.0) - 50
  for level: String in dir.get_directories():
    var node := %lvlSelItem.duplicate()
    node.get_node("VBoxContainer/Label").text = level
    var data = global.loadLevelPackInfo(level)
    node.get_node("VBoxContainer/Label2").text = "Author: " + data.author
    node.get_node("VBoxContainer/Label3").text = data.description
    node.get_node('VBoxContainer/Button').connect("pressed", loadLevel.bind(level, false))
    node.get_node('VBoxContainer/Button2').connect("pressed", loadLevel.bind(level, true))
    $ScrollContainer/HFlowContainer.add_child(node)
  %lvlSelItem.queue_free.call_deferred()
  loadUserOptions()

func loadLevel(level, fromSave) -> void:
  global.useropts = m.get_all_data()
  # log.pp(global.useropts)
  global.loadLevelPack(level, fromSave)

func loadUserOptions() -> void:
  var data = global.file.read("res://scenes/main menu/userOptsMenu.jsonc")
  var OBJECT = typeof({})
  m = Menu.new($VBoxContainer)
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
  m.show_menu()

func __loadOptions(thing) -> void:
  match thing["type"]:
    "bool":
      m.add_bool(thing["key"], thing["defaultValue"])
    "int":
      m.add_range(
        thing["key"],
        thing['min'],
        thing['max'],
        thing['step'] if "step" in thing else 1,
        thing["defaultValue"],
        thing['allow lesser'] if "allow lesser" in thing else false,
        thing['allow greater'] if "allow greater" in thing else false
      )
    "float":
      m.add_float(thing["key"], thing["defaultValue"])
