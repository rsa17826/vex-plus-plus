extends Control

var containers: Array[FoldableContainer] = []
@export var optsmenunode: Control

var __menu: Menu
var editorOnlyOptions := []
var waitingForMouseUp := false

func _init() -> void:
  global.tabMenu = self

func __loadOptions(thing) -> void:
  if 'editorOnly' in thing and thing.editorOnly and not OS.has_feature("editor"):
    editorOnlyOptions.append(thing)
    return
  match thing.thing:
    "group":
      __menu.startGroup(thing.name)
      # log.pp(thing.name, thing.value)
      for a in thing.value:
        __loadOptions(a)
      __menu.endGroup()
    'option':
      match thing.type:
        "lineedit":
          __menu.add_lineedit(thing.key, thing.defaultValue, thing.placeholder if 'placeholder' in thing else '')
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
        "file":
          __menu.add_file(
            thing.key,
            thing.single if "single" in thing else true,
            thing.defaultValue,
          )

func _input(event: InputEvent) -> void:
  if event is InputEventKey:
    if Input.is_action_just_pressed(&"toggle_tab_menu", true):
      visible = !visible
      get_parent().visible = visible
      if visible:
        Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func _ready() -> void:
  get_parent().visible = false
  visible = false
  updateSize()
  var data = global.file.read("res://scenes/main menu/userOptsMenu.jsonc")
  __menu = Menu.new(optsmenunode)
  __menu.onchanged.connect(updateUserOpts)
  for thing in data:
    __loadOptions(thing)
  __menu.show_menu()

func updateUserOpts() -> void:
  var shouldReload = false
  var shouldChangeFsState = false
  var lastWinMode
  if 'windowMode' not in global.useropts:
    shouldChangeFsState = true
  else:
    lastWinMode = global.useropts.windowMode
  var lastTheme = global.useropts.theme if 'theme' in global.useropts else null
  global.useropts = __menu.get_all_data()
  # log.pp('editorOnlyOptions', editorOnlyOptions)
  for option in editorOnlyOptions:
    global.useropts[option.key] = option.defaultValue

  if lastWinMode == null or lastWinMode != global.useropts.windowMode:
    shouldChangeFsState = true
  # log.pp(lastTheme, global.useropts.theme, "asd")
  if shouldChangeFsState or global.isFirstTimeMenuIsLoaded:
    if global.isFirstTimeMenuIsLoaded:
      get_window().size = Vector2(1152, 648)
      await global.wait()
    match int(global.useropts.windowMode):
      0:
        global.fullscreen(1)
      1:
        global.fullscreen(-1)

  if global.useropts.theme != lastTheme:
    if global.useropts.theme == 0:
      get_window().theme = null
    else:
      get_window().theme = load("res://themes/" + ["default", "blue", "black"][global.useropts.theme] + "/THEME.tres")
    RenderingServer.set_default_clear_color(["#4d4d4d", "#4b567aff", "#4d4d4d"][global.useropts.theme])
    shouldReload = true
  sds.prettyPrint = !global.useropts.smallerSaveFiles
  if shouldReload:
    global.level.save()
    global.loadMap.call_deferred(global.mainLevelName, true)
  global.hitboxTypesChanged.emit()
  if waitingForMouseUp: return
  if Input.is_mouse_button_pressed(MouseButton.MOUSE_BUTTON_LEFT):
    waitingForMouseUp = true
    while Input.is_mouse_button_pressed(MouseButton.MOUSE_BUTTON_LEFT):
      await global.wait(100)
    waitingForMouseUp = false
  updateSize.call_deferred()

func updateSize():
  size = Vector2(1152.0, 648.0) / global.useropts.tabMenuScale
  scale = Vector2(global.useropts.tabMenuScale, global.useropts.tabMenuScale)
  log.pp(size, scale, global.useropts.tabMenuScale)
