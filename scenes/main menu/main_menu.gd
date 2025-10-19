extends Control

var GITHUB_TOKEN = global.getToken()

@export var optsmenunode: Control
@export var levelContainer: Control
@export var scrollContainer: ScrollContainer
@export var loginMenuBg: Control
@export var searchBar: Control
@export var gameVersionNode: Label
@export var currentUserInfoNode: Label

var __menu: Menu
var newestLevel
func _init() -> void:
  global.mainMenu = self

@onready var pm: PopupMenu = PopupMenu.new()

func _ready() -> void:
  add_child(pm)
  # loadUserOptions()
  loadLocalLevelList()
  gameVersionNode.text = "VERSION: " + str(global.VERSION)
  if !global.isFirstTimeMenuIsLoaded:
    LevelServer.updateCurrentUserInfoNode()
    global.loadEditorBarData()
  var shouldReload = false
  if global.isFirstTimeMenuIsLoaded:
    var levelToLoad
    global.isFirstTimeMenuIsLoaded = false
    var arr: Array = OS.get_cmdline_args() as Array
    while arr:
      var thing = arr.pop_front()
      if thing == '--loadMap':
        var mapName = arr.pop_front()
        shouldReload = false
        if mapName == 'NEWEST':
          levelToLoad = global.mainMenu.newestLevel
        else:
          levelToLoad = mapName
      if thing == '--downloadMap':
        var data = arr.pop_front()
        shouldReload = true
        var map = await LevelServer.loadMapById(data.trim_prefix("vex++:downloadMap/").split("/")[1])
        if map:
          await LevelServer.downloadMap(map)
          await global.wait(1000)
          ToastParty.success("Downloaded successfully")
        else:
          ToastParty.error("Invalid map id")
      if thing == '--loadOnlineLevels':
        shouldReload = false
        get_tree().change_scene_to_file("res://scenes/online level list/main.tscn")
        return
    if levelToLoad:
      await global.wait()
      await global.loadMap(levelToLoad, true)
  if shouldReload:
    get_tree().reload_current_scene.call_deferred()
  scrollContainer.set_deferred('scroll_vertical', int(global.file.read("user://scrollContainerscroll_vertical", false, "0")))
  searchBar.set_deferred("text", global.file.read("user://localLevelListSearchBarFilterText", false, ""))
  scrollContainer.gui_input.connect(func(event):
    # scroll up or down then save scroll position
    if event.button_mask == 8 || event.button_mask == 16:
      global.file.write("user://scrollContainerscroll_vertical", str(scrollContainer.scroll_vertical), false))

func loadLevelsFromArray(newData: Array, showOldVersions:=false) -> Array:
  for child in levelContainer.get_children():
    child.queue_free()
  const levelNode := preload("res://scenes/online level list/level display.tscn")
  var nodes = []
  for level in newData:
    var node = levelNode.instantiate()
    node.levelList = self
    node.search = searchBar
    node.isOnline = false
    node.showLevelData(level)
    nodes.append(node)
    levelContainer.add_child(node)
  return nodes

func loadLocalLevelList():
  Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
  var dir := DirAccess.open(global.MAP_FOLDER)
  var dirs = (dir.get_directories() as Array).filter(func(e):return FileAccess.file_exists(global.path.join(global.MAP_FOLDER, e, 'options.sds')))
  dirs.sort_custom(func(a: String, s: String):
    return \
    FileAccess.get_modified_time(global.path.join(global.MAP_FOLDER, a, 'options.sds')) \
    > FileAccess.get_modified_time(global.path.join(global.MAP_FOLDER, s, 'options.sds'))
  )
  newestLevel = dirs[0] if dirs else null
  for child in levelContainer.get_children():
    child.queue_free()
  const levelNode := preload("res://scenes/online level list/level display.tscn")
  var i = 0
  for mapName: String in dirs:
    i+=1
    var data = global.loadMapInfo(mapName)
    var saveData: Variant = sds.loadDataFromFile(global.getLevelSavePath(mapName), null)
    if not data:
      log.err(mapName, "no data found")
      continue
    if global.useropts.showLevelCompletionInfoOnMainMenu:
      var starText = "???"
      var levelText = "???"
      data.completionInfo="LEVELS: "+levelText+" STARS: "+starText+" = "+"??%"
      if saveData:
        if 'stages' in data:
          var beatLevelCount :float= 0
          var totalLevelCount:float = 0
          var collectedStarCount:float = 0
          var totalApproxStarCount:float = 0
          if 'beatLevels' in saveData and 'loadedLevels' in saveData:
            var beatLevelNames = saveData.beatLevels.map(func(e):return e.name if 'name' in e else "NO NAME SET!!/")
            var loadedLevelNames = saveData.loadedLevels.map(func(e):return e.name if 'name' in e else "NO NAME SET!!/")
            for levelName in data.stages:
              if levelName in loadedLevelNames:
                var temp = saveData.loadedLevels[saveData.loadedLevels.find_custom(func(e):return e.name == levelName)]
                if 'blockSaveData' in temp:
                  if "star" in temp.blockSaveData:
                    for star in temp.blockSaveData.star:
                      totalApproxStarCount+=1
              elif levelName in beatLevelNames:
                var temp = saveData.beatLevels[saveData.beatLevels.find_custom(func(e):return e.name == levelName)]
                if 'blockSaveData' in temp:
                  if "star" in temp.blockSaveData:
                    for star in temp.blockSaveData.star:
                      if star.collected:
                        collectedStarCount+=1
                      totalApproxStarCount+=1
                beatLevelCount+=1
              totalLevelCount+=1
            if "beatMainLevel" in saveData and saveData.beatMainLevel:
              beatLevelCount+=1
            if beatLevelCount+1>=totalLevelCount:
              starText=str(int(collectedStarCount))+"/"+str(int(totalApproxStarCount))
            else:
              starText=str(int(collectedStarCount))+"/?"+str(int(totalApproxStarCount))+"?"
            starText += " "+str(int(floor(collectedStarCount/totalApproxStarCount*100) if totalApproxStarCount else 100))+"%"
            levelText = str(int(floor(beatLevelCount/totalLevelCount*100) if totalLevelCount else 0))+"%"
            # log.pp(mapName, levelText, starText)
            data.completionInfo="LEVELS: "+levelText+" STARS: "+starText+" = "+str(int(floor((beatLevelCount/totalLevelCount*100)*(collectedStarCount/totalApproxStarCount if totalApproxStarCount else 1)) if totalLevelCount else 0))+"%"
    data.levelName = mapName
    var imagePath = global.path.join(global.MAP_FOLDER, mapName, "image.png")
    if FileAccess.file_exists(imagePath):
      data.levelImage = Image.load_from_file(imagePath)
    else:
      data.levelImage = null
    var node = levelNode.instantiate()
    node.levelList = self
    node.search = searchBar
    node.isOnline = false
    node.showLevelData(LevelServer.dictToLevel(data))
    levelContainer.add_child(node)
    if i% global.useropts.amountOfLevelsToLoadAtTheSameTimeOnMainMenu==0:
      await global.wait()


func otc(text: String, version: NestedSearchable):
  if not version: return
  version.updateSearch(text)
signal onTextChanged

var levelMenuPromise
func showMoreOptions(level: LevelServer.Level):
  var levelName = level.levelName
  pm.system_menu_id = NativeMenu.SystemMenus.DOCK_MENU_ID
  var i := 0
  pm.clear()
  for k: String in [
    "duplicate",
    "delete",
    "rename",
    "-",
    "show in file explorer",
    "open settings file",
    "edit description",
    "-",
    "export",
    "upload",
    "restore level from downloaded state",
  ]:
    if k[0] == '-':
      pm.add_separator(k.trim_prefix("-"), i)
    else:
      pm.add_item(k, i)
    i += 1
  # pm.add_separator("ASFD")
  # pm.add_item('< cancel >', i)
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
      OS.move_to_trash(global.path.join(global.MAP_FOLDER, levelName + " (copy)"))
      global.copyDir(
        global.path.join(global.MAP_FOLDER, levelName),
        global.path.join(global.MAP_FOLDER, levelName + " (copy)")
      )
      loadLocalLevelList()
      if FileAccess.file_exists(global.getLevelSavePath(levelName)):
        sds.saveDataToFile(global.getLevelSavePath(levelName + " (copy)"), sds.loadDataFromFile(global.getLevelSavePath(levelName)))
    1:
      OS.move_to_trash(global.path.join(global.MAP_FOLDER, levelName))
      loadLocalLevelList()
    2:
      var newName = (await global.prompt(
        "Rename map",
        global.PromptTypes.string,
        levelName
      )).replace("/", '').replace("\\", '')
      if newName!=levelName:
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
    4:
      OS.shell_open(global.path.join(global.MAP_FOLDER, levelName))
    5:
      OS.shell_open(global.path.join(global.MAP_FOLDER, levelName, "options.sds"))
    6:
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
    8:
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
    9:
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

      var gameVersion = str(data.gameVersion)
      var creatorName = data.creatorName if "creatorName" in data else data.author
      # var c = Marshalls.raw_to_base64(f.get_buffer(f.get_length()))
      var c = f.get_buffer(f.get_length())
      if not creatorName:
        ToastParty.err("Please enter an creatorName name")
        return
      if not levelName:
        ToastParty.err("Please enter a map name")
        return
      $AnimatedSprite2D.visible = true
      var img = Image.new()
      img.load(global.path.join(global.MAP_FOLDER, levelName, "/image.png"))
      if img.get_size() != Vector2i(292, 292):
        ToastParty.err("the map must have a valid image - a valid image is created by saving the map!")
        return
      if 'levelVersion' not in data:
        data.levelVersion = -1
      f.close()
      if await LevelServer.uploadLevel(
        LevelServer.Level.new(
          levelName,
          - 1,
          data.description,
          '',
          creatorName,
          data.gameVersion,
          data.levelVersion,
          c,
          img
        )
      ):
        ToastParty.success("Level uploaded!")
      $AnimatedSprite2D.visible = false
    10:
      if ! await global.prompt("Are you sure you want to restore this level?", global.PromptTypes.confirm): return
      if await global.tryAndGetMapZipsFromArr([global.path.abs("res://downloaded maps/" + levelName + '.vex++')]):
        ToastParty.success("The map has been successfully restored.")
      else:
        ToastParty.error("restoring failed, the map doesn't exist, or the map was invalid.")

var editorOnlyOptions := []

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
            thing['allow greater'] if "allow greater" in thing else false,
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
            thing['allow greater'] if "allow greater" in thing else false,
            thing.rounded if "rounded" in thing else false
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
  # updateUserOpts()
  global.loadMap(level, false)

func _on_open_level_folder_pressed() -> void:
  OS.shell_open(global.path.abs(global.MAP_FOLDER))

func _on_load_online_levels_pressed() -> void:
  get_tree().change_scene_to_file("res://scenes/online level list/main.tscn")

func _on_open_readme_pressed() -> void:
  OS.shell_open("https://github.com/rsa17826/vex-plus-plus#vex")

func _on_change_keybinds_pressed() -> void:
  global.ctrlMenu.visible = !global.ctrlMenu.visible

func _on_open_logs_pressed() -> void:
  OS.shell_open(global.path.abs("user://logs/godot.log"))

func _on_show_login_pressed() -> void:
  loginMenuBg.visible = true

func _on_login_close_button_pressed() -> void:
  loginMenuBg.visible = false

func _on_quit_pressed() -> void:
  global.quitGame()

func _on_search_text_changed(new_text: String, textArr: Array) -> void:
  global.file.write("user://localLevelListSearchBarFilterText", new_text, false)
