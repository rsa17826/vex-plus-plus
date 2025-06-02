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
  for k: String in ["duplicate", "delete", "rename", "share"]:
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
  get_tree().reload_current_scene()
  
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
