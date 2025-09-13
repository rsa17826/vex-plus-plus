extends Control

var GITHUB_TOKEN = global.getToken()

@export var optsmenunode: Control
@export var levelContainer: Control
@export var scrollContainer: ScrollContainer
@export var loginMenuBg: Control

var __menu: Menu
var newestLevel

@onready var pm: PopupMenu = PopupMenu.new()
func _on_search_text_changed(new_text: String) -> void:
  onTextChanged.emit(new_text)

func _ready() -> void:
  add_child(pm)
  loadUserOptions()
  loadLocalLevelList()
  %version.text = "VERSION: " + str(global.VERSION)

func loadLocalLevelList():
  const levelNode = preload("res://scenes/main menu/lvl_sel_item.tscn")
  Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
  var dir := DirAccess.open(global.MAP_FOLDER)
  var dirs = (dir.get_directories() as Array)
  var allData = {}
  for levelName: String in dirs:
    var data = global.loadMapInfo(levelName)
    if data.version not in allData:
      allData[data.version] = {}
    if data.author not in allData[data.version]:
      allData[data.version][data.author] = {}
    allData[data.version][data.author][levelName] = data
  # log.pp(allData)

  for child in levelContainer.get_children():
    child.queue_free()
  var arr := allData.keys()
  arr.sort()
  arr.reverse()
  newestLevel = allData[arr[0]][allData[arr[0]].keys()[0]].keys()[0] if dirs else null
  var launcherExists = FileAccess.file_exists("../../vex++.exe") or FileAccess.file_exists(r"..\..\vex++.cmd")
  # log.pp(newestLevel)
  const versionNode := preload("res://scenes/online level list/version.tscn")
  const creatorNode := preload("res://scenes/online level list/creator.tscn")
  # const levelNode := preload("res://scenes/online level list/level.tscn")
  for version in arr:
    var v = versionNode.instantiate()
    v.title = str(version)
    v.folded = false if global.useropts.autoExpandAllGroupsInLocalLevelList else version != global.VERSION
    v.thisText = str(version).to_lower().replace('\n', '')
    levelContainer.add_child(v)
    for creator in allData[version]:
      var c = creatorNode.instantiate()
      c.title = creator
      c.thisText = creator.to_lower().replace('\n', '')
      v.get_node("VBoxContainer").add_child(c)
      for levelName in allData[version][creator]:
        var data = allData[version][creator][levelName]
        var description = data.description
        var l = levelNode.instantiate()
        onTextChanged.connect(func(text): otc.call(text, v), ConnectFlags.CONNECT_DEFERRED)
        l.levelname.text = levelName
        var versiontext = "V" + str(data.version) + " "
        if data.version > global.VERSION:
          versiontext += ">"
        elif data.version < global.VERSION:
          versiontext += "<"
        else:
          versiontext += "="
        l.openInCorrectVersion.text = 'open in ' + versiontext
        l.version.text = versiontext
        l.openInCorrectVersion.visible = data.version != global.VERSION and launcherExists
        l.openInCorrectVersion.version = data.version
        l.openInCorrectVersion.levelName = levelName
        l.version.visible = data.version == global.VERSION or not launcherExists
        l.thisText = l.levelname.text.to_lower().replace('\n', '')
        l.newSaveBtn.connect("pressed", loadLevel.bind(levelName, false))
        l.tooltip_text = description if description else "NO DESCRIPTION SET"
        l.loadSaveBtn.connect("pressed", loadLevel.bind(levelName, true))
        l.moreOptsBtn.connect("pressed", showMoreOptions.bind(levelName, data))
        c.get_node("VBoxContainer").add_child(l)

func otc(text: String, version: NestedSearchable):
  if not version: return
  version.updateSearch(text)
signal onTextChanged

var levelMenuPromise
func showMoreOptions(levelName, levelData):
  pm.system_menu_id = NativeMenu.SystemMenus.DOCK_MENU_ID
  var i := 0
  pm.clear()
  for k: String in [
    "duplicate",
    "delete",
    "rename",
    "show in file explorer",
    "open settings file",
    "edit description",
    "export",
    "upload",
    "restore level from downloaded state",
    "copy level share code",
  ]:
    pm.add_item(k, i)
    i += 1
  pm.add_item('< cancel >', i)
  if levelMenuPromise:
    levelMenuPromise.resolve(-1)
  levelMenuPromise = Promise.new()
  pm.index_pressed.connect(func(e):
    if levelMenuPromise:
      levelMenuPromise.resolve(e)
    levelMenuPromise=null, CONNECT_ONE_SHOT)
  pm.popup.call_deferred(Rect2i(get_screen_transform() * get_local_mouse_position(), Vector2i.ZERO))
  var res = await levelMenuPromise.wait()
  log.pp(res)
  match res:
    -1: return
    0:
      global.copyDir(
        global.path.join(global.MAP_FOLDER, levelName),
        global.path.join(global.MAP_FOLDER, levelName + " (copy)")
      )
      loadLocalLevelList()
    1:
      OS.move_to_trash(global.path.join(global.MAP_FOLDER, levelName))
      loadLocalLevelList()
    2:
      var newName = (await global.prompt(
        "Rename map",
        global.PromptTypes.string,
        levelName
      )).replace("/", '').replace("\\", '')
      DirAccess.rename_absolute(
        global.path.join(global.MAP_FOLDER, levelName),
        global.path.join(global.MAP_FOLDER,
          newName
        )
      )
      var saveData: Dictionary = sds.loadDataFromFile(global.getLevelSavePath(levelName), {})
      if levelName in saveData:
        saveData[newName] = saveData[levelName]
        saveData.erase(levelName)
        sds.saveDataToFile(global.getLevelSavePath(newName), saveData)
        OS.move_to_trash(global.getLevelSavePath(levelName))
      loadLocalLevelList()
    3:
      OS.shell_open(global.path.join(global.MAP_FOLDER, levelName))
    4:
      OS.shell_open(global.path.join(global.MAP_FOLDER, levelName, "options.sds"))
    5:
      var data = global.loadMapInfo(levelName)
      var desc: String = await global.prompt(
        "enter description",
        global.PromptTypes.multiLineString,
        data.description
      )
      if data.description != desc:
        data.description = desc
        data.levelVersion += 1
        sds.saveDataToFile(global.path.join(global.MAP_FOLDER, levelName, "/options.sds"), data)
        loadLocalLevelList()
    6:
      # log.pp(levelName)
      if FileAccess.file_exists(global.path.abs("res://exports/" + levelName + ".vex++")):
        OS.move_to_trash(global.path.abs("res://exports/" + levelName + ".vex++"))
        await global.wait(100)
      global.zipDir(
        global.path.join(global.MAP_FOLDER, levelName),
        global.path.abs("res://exports/" + levelName + ".vex++")
      )
      ToastParty.info("map exported successfully")
      if global.useropts.openExportsDirectoryOnExport:
        OS.shell_open(global.path.abs("res://exports"))
    7:
      if not LevelServer.user:
        _on_show_login_pressed()
        await global.waituntil(func():
          return !loginMenuBg.visible)
        if not LevelServer.user:
          ToastParty.err("you must login to upload maps")
          return
      if !FileAccess.file_exists(global.path.join(global.MAP_FOLDER, levelName, "/image.png")):
        ToastParty.err("the map must have an image - an image is created by saving the map!")
        return
      var outpath = global.path.abs("res://exports/" + levelName + ".vex++")
      global.zipDir(
        global.path.join(global.MAP_FOLDER, levelName),
        outpath
      )
      var f = FileAccess.open(outpath, FileAccess.READ)
      var data = sds.loadDataFromFile(global.path.join(global.MAP_FOLDER, levelName, "/options.sds"))

      var version = str(data.version)
      var author = data.author
      # var c = Marshalls.raw_to_base64(f.get_buffer(f.get_length()))
      var c = f.get_buffer(f.get_length())
      if not author:
        ToastParty.err("Please enter an author name")
        return
      if not levelName:
        ToastParty.err("Please enter a map name")
        return
      $AnimatedSprite2D.visible = true
      var img = Image.new()
      img.load(global.path.join(global.MAP_FOLDER, levelName, "/image.png"))
      if img.get_size() != Vector2i(292, 292):
        ToastParty.err("the map must have an image of a valid size - a valid image is created by saving the map!")
        return
      if 'levelVersion' not in data:
        data.levelVersion = -1
      await LevelServer.uploadLevel(
        LevelServer.Level.new(
          levelName,
          - 1,
          data.description,
          '',
          author,
          data.version,
          data.levelVersion,
          c,
          img
        )
      )
      $AnimatedSprite2D.visible = false
      f.close()
      ToastParty.success("Level uploaded!")
    8:
      if ! await global.prompt("Are you sure you want to restore this level?", global.PromptTypes.confirm): return
      if await global.tryAndGetMapZipsFromArr([global.path.abs("res://downloaded maps/" + levelName + '.vex++')]):
        ToastParty.success("The map has been successfully restored.")
      else:
        ToastParty.error("restoring failed, the map doesn't exist, or the map was invalid.")
    9:
      # log.pp(levelData, levelData.author)
      if not levelData.author:
        ToastParty.err("authors name must be set")
        return
      var levelCode = 'vex++:downloadMap/' + str(levelData.version) + '/' + levelData.author + "/" + levelName
      if levelCode.find("//") != -1:
        ToastParty.err("invalid level data " + levelCode)
        log.err(levelCode)
        return
      var url = (
        "https://raw.githubusercontent.com/rsa17826/" +
        global.REPO_NAME + "/" + global.BRANCH + "/levels/" +
        global.urlEncode(str(levelData.version) + '/' + levelData.author + "/" + levelName) + '.vex++?rand=' + str(randf())
      )
      var data = await global.httpGet(url, [], HTTPClient.METHOD_GET)
      if data.code == 200:
        DisplayServer.clipboard_set(levelCode)
        ToastParty.success("level code copied to clipboard")
      else:
        ToastParty.err("level has not been uploaded. it must be uploaded before the code will work")
        DisplayServer.clipboard_set(levelCode)
      # log.pp(data.code, data, levelData, levelData.author, url)

# https://api.github.com/repos/rsa17826/vex-plus-plus-level-codes/contents/

func loadLevel(level, fromSave) -> bool:
  global.hitboxesShown = global.useropts.showHitboxesByDefault
  get_tree().set_debug_collisions_hint(global.hitboxesShown)
  return await global.loadMap(level, fromSave)

var editorOnlyOptions := []

func loadUserOptions() -> void:
  var data = global.file.read("res://scenes/main menu/userOptsMenu.jsonc")
  __menu = Menu.new(optsmenunode)
  __menu.onchanged.connect(updateUserOpts)
  for thing in data:
    __loadOptions(thing)
  __menu.show_menu()
  scrollContainer.set_deferred('scroll_vertical', int(global.file.read("user://scrollContainerscroll_vertical", false, "0")))
  scrollContainer.gui_input.connect(func(event):
    # scroll up or down then save scroll position
    if event.button_mask == 8 || event.button_mask == 16:
      global.file.write("user://scrollContainerscroll_vertical", str(scrollContainer.scroll_vertical), false))
  updateUserOpts()

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
  global.loadEditorBarData()
  if global.isFirstTimeMenuIsLoaded:
    global.isFirstTimeMenuIsLoaded = false
    var arr: Array = OS.get_cmdline_args() as Array
    while arr:
      var thing = arr.pop_front()
      if thing == '--loadMap':
        var mapName = arr.pop_front()
        shouldReload = false
        if mapName == 'NEWEST':
          if await loadLevel(newestLevel, true): return
        else:
          if await loadLevel(mapName, true): return
      if thing == '--downloadMap':
        var data = arr.pop_front()
        shouldReload = true
        if !data.ends_with('.vex++'): data += '.vex++'
        await global.downloadMap(data.split("/")[0], data.split("/")[1], data.split("/")[2])
      if thing == '--loadOnlineLevels':
        shouldReload = false
        get_tree().change_scene_to_file("res://scenes/online level list/main.tscn")
        return

  if shouldReload:
    get_tree().reload_current_scene.call_deferred()

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

func _on_new_level_btn_pressed() -> void:
  var level = await global.createNewMapFolder()
  if not level: return
  updateUserOpts()
  loadLevel(level, false)

func _on_open_level_folder_pressed() -> void:
  OS.shell_open(global.path.abs(global.MAP_FOLDER))

func _on_load_online_levels_pressed() -> void:
  get_tree().change_scene_to_file("res://scenes/online level list/main.tscn")

func _on_open_readme_pressed() -> void:
  OS.shell_open("https://github.com/rsa17826/vex-plus-plus#vex")

func _on_change_keybinds_pressed() -> void:
  $CTRLS.visible = !$CTRLS.visible

func _on_open_logs_pressed() -> void:
  OS.shell_open(global.path.abs("user://logs/godot.log"))

func _on_show_login_pressed() -> void:
  loginMenuBg.visible = true

func _on_login_close_button_pressed() -> void:
  loginMenuBg.visible = false
