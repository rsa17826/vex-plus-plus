extends Control

var containers: Array[FoldableContainer] = []
@export var optsmenunode: Control
@export var isOptionsMenuOnMainMenu: bool = false

var __menu: Menu
# sets visible for self and required parents
var _visible:
  set(val):
    visible = val
    if isOptionsMenuOnMainMenu:
      get_parent().get_parent().visible = visible
    else:
      if val:
        if global.useropts.alwaysShowMenuOnHomePage or global.useropts.optionMenuToSideOnMainMenuInsteadOfOverlay:
          __menu.reloadDataFromFile()
          __menu.reloadUi()
      updateSize()
      get_parent().visible = visible
  get():
    return visible

var editorOnlyOptions := []
var waitingForMouseUp := false

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

func _input(event: InputEvent) -> void:
  # var focus = get_viewport().gui_get_focus_owner()
  # if focus is LineEdit or focus is TextEdit: return
  if event is InputEventKey:
    if Input.is_action_just_pressed(&"toggle_tab_menu", true):
      if global.useropts.optionMenuToSideOnMainMenuInsteadOfOverlay and isOptionsMenuOnMainMenu:
        global.file.write("user://mainMenuOptionsMenuVisible", str(visible), false)
      if global.isAlive(global.mainMenu) and global.useropts.optionMenuToSideOnMainMenuInsteadOfOverlay:
        if !isOptionsMenuOnMainMenu: return
      else:
        if isOptionsMenuOnMainMenu: return
      get_viewport().set_input_as_handled()
      _visible = !visible
      if visible:
        Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func _ready() -> void:
  var data = global.file.read("res://scenes/main menu/userOptsMenu.jsonc")
  __menu = Menu.new(optsmenunode)
  __menu.onchanged.connect(updateUserOpts)
  for thing in data:
    __loadOptions(thing)
  __menu.startGroup("open in explorer")
  __menu.add_button("open editor bar file", func():
    OS.shell_open(global.path.abs("res://editorBar.sds"))
  )
  __menu.add_button("open current level folder", func():
    if global.mainLevelName and global.isAlive(global.level):
      OS.shell_open(global.path.abs("res://maps/" + global.mainLevelName))
    else:
      OS.shell_open(global.path.abs("res://maps"))
  )
  __menu.add_button("open current level save file", func():
    if global.mainLevelName and global.isAlive(global.level):
      OS.shell_open(global.path.abs("res://saves/" + global.mainLevelName + '.sds'))
    else:
      OS.shell_open(global.path.abs("res://saves"))
  )
  __menu.add_button("open menu settings file", func():
    OS.shell_open(global.path.abs("user://main" + \
    (" - EDITOR" if OS.has_feature("editor") else '') \
    + ".sds"))
  )
  __menu.endGroup()
  __menu.startGroup("extra buttons")
  __menu.add_button("create images for all levels that don't have images", createImagesForAllLevelsHaveImages.bind(true))
  __menu.add_button("create images for all levels", createImagesForAllLevelsHaveImages.bind(false))
  __menu.endGroup()
  __menu.show_menu()
  updateUserOpts()
  if isOptionsMenuOnMainMenu:
    if global.useropts.alwaysShowMenuOnHomePage || global.useropts.optionMenuToSideOnMainMenuInsteadOfOverlay:
      _visible = global.file.read("user://mainMenuOptionsMenuVisible", false, "true") == "true"
    else:
      _visible = false
  else:
    global.overlays.append(self)
    _visible = false
    global.tabMenu = self
func createImagesForAllLevelsHaveImages(ignoreOnesWithImages) -> void:
  Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
  var dir := DirAccess.open(global.MAP_FOLDER)
  var dirs = (dir.get_directories() as Array)
  var arr = []
  for levelName: String in dirs:
    var imagePath = global.path.join(global.MAP_FOLDER, levelName, "image.png")
    if ignoreOnesWithImages and FileAccess.file_exists(imagePath): continue
    arr.append(levelName)
  arr.sort_custom(func(a: String, s: String):
    return \
    FileAccess.get_modified_time(global.path.join(global.MAP_FOLDER, a, 'options.sds')) \
    > FileAccess.get_modified_time(global.path.join(global.MAP_FOLDER, s, 'options.sds'))
  )
  global.tabMenu.get_node("../../progress").visible = true
  var pbar = global.tabMenu.get_node("../../progress/CenterContainer/progressBar")
  global.tabMenu._visible = true
  pbar.max_value = len(arr)
  var prog = 0
  for levelName in arr:
    if await global.loadMap(levelName, false):
      global.level.save(true)
      await global.wait()
    prog += 1
    pbar.value = prog
  global.tabMenu.get_node("../../progress").visible = false
func updateUserOpts(thingChanged: String = '') -> void:
  var ftml = global.isFirstTimeMenuIsLoaded
  var shouldChangeFsState = false
  var lastWinMode
  if 'windowMode' not in global.useropts:
    shouldChangeFsState = true
  else:
    lastWinMode = global.useropts.windowMode
  global.useropts = __menu.get_all_data()
  # log.pp('editorOnlyOptions', editorOnlyOptions)
  for option in editorOnlyOptions:
    global.useropts[option.key] = option.defaultValue

  if lastWinMode == null or lastWinMode != global.useropts.windowMode:
    shouldChangeFsState = true
  # log.pp(lastTheme, global.useropts.theme, "asd")
  if shouldChangeFsState or ftml:
    if ftml:
      get_window().size = Vector2(1152, 648)
      await global.wait()
    match int(global.useropts.windowMode):
      0:
        global.fullscreen(1)
      1:
        global.fullscreen(-1)
  sds.prettyPrint = !global.useropts.smallerSaveFiles
  global.hitboxesShown = global.useropts.showHitboxesByDefault
  global.hitboxTypesChanged.emit()
  if thingChanged.begins_with("startGroup - "): return
  match thingChanged:
    "", \
    "smallerSaveFiles", \
    "showHitboxesByDefault", \
    "saveOnExit", \
    "saveLevelOnWin", \
    "showIconOnSave", \
    "blockGridSnapSize", \
    "showGridInEdit", \
    "showGridInPlay", \
    "windowMode", \
    "warnWhenOpeningLevelInOlderGameVersion", \
    "warnWhenOpeningLevelInNewerGameVersion", \
    "confirmKeyAssignmentDeletion", \
    "confirmLevelUploads", \
    "multiSelectedBlocksRotationScheme", \
    "randomizeLevelModifiersOnLevelCreation", \
    "minDistBeforeBlockDraggingStarts", \
    "amountOfLevelsToLoadAtTheSameTimeOnMainMenu", \
    "autoPanWhenClickingEmptySpace", \
    "movingPathNodeMovesEntirePath", \
    "newlyCreatedBlocksRotationTakesPlayerRotation", \
    "deleteLastSelectedBlockIfNoBlockIsCurrentlySelected", \
    "mouseLockDistanceWhileRotating", \
    "editorScrollSpeed", \
    "noCornerGrabsForScaling", \
    "blockGhostAlpha", \
    "singleAxisAlignByDefault", \
    "editorBarScrollSpeed", \
    "allowRotatingAnything", \
    "allowScalingAnything", \
    "cameraUsesDefaultRotationInEditor", \
    "dontChangeCameraRotationOnGravityChange", \
    "cameraRotationOnGravityChangeHappensInstantly", \
    "selectedBlockOutlineColor", \
    "hoveredBlockOutlineColor", \
    "toastStayTime", \
    "snapCameraToPixels", \
    "showHoveredBlocksList", \
    "selectedBlockFormatString", \
    "hoveredBlockFormatString", \
    "showSignalListInEditor", \
    "showSignalListInPlay", \
    "onlyShowSignalConnectionsIfHoveringOverAny", \
    "showLevelModsWhileEditing", \
    "showLevelModsWhilePlaying", \
    "showLevelLoadingProgressBar", \
    "showLevelLoadingBehindProgressBar", \
    "showPathBlockInPlay", \
    "showPathLineInPlay", \
    "showPathEditNodesInPlay", \
    "defaultCreatorName", \
    "defaultCreatorNameIsLoggedInUsersName", \
    "loadOnlineLevelListOnSceneLoad", \
    "removeUnusedItemsFromMenuSaveFile", \
    "__slowTime", \
    "__allowCheckpointReentryOnDeath", \
    "showSolidHitboxes", \
    "showAttachDetectorHitboxes", \
    "showAreaHitboxes", \
    "showDeathHitboxes", \
    "deathHitboxColor", \
    "areaHitboxColor", \
    "attachDetectorHitboxColor", \
    "solidHitboxColor", \
    "openExportsDirectoryOnExport", \
    "tabMenuScale", \
    # ?
    "autosaveInterval", \
    # /?
    "theme": pass
    "dontCollapseGroups", \
    "saveExpandedGroups", \
    "loadExpandedGroups", \
    "menuOptionNameFormat":
      __menu.reloadUi()
    "cameraZoomInPlay", \
    "cameraZoomInEditor":
      global.onEditorStateChanged.emit()
    "levelTilingBackgroundPath", \
    "editorBackgroundPath", \
    "editorStickerPath", \
    "editorBackgroundScaleToMaxSize", \
    "showTotalActiveSignalCounts", \
    "showWhatBlocksAreSendingSignals", \
    "onlyShowActiveSignals", \
    "showUnchangedLevelMods", \
    "allowCustomColors":
      if global.isAlive(global.level):
        global.level.save(false)
        global.loadMap.call_deferred(global.mainLevelName, true)
    "showSignalConnectionLinesOnHover", \
    "showSignalConnectionLinesInEditor", \
    "showSignalConnectionLinesInPlay":
      if global.isAlive(global.level):
        for block in global.level.get_node("blocks").get_children():
          if block is EditorBlock:
            block.queue_redraw()
    "editorBarBlockSize", \
    "editorBarOffset", \
    "editorBarPosition", \
    "showEditorBarBlockMissingErrors", \
    "editorBarColumns", \
    "reorganizingEditorBar" \
    :
      if global.isAlive(global.editorBar):
        global.loadEditorBarData()
        global.editorBar.reload()
    'showAutocompleteOptions', \
    "autocompleteSearchBarHookLeftAndRight", \
    "searchBarHorizontalAutocomplete":
      if not global.isAlive(global.level):
        get_tree().reload_current_scene()
    "smallLevelDisplaysInLocalLevelList":
      if global.isAlive(global.mainMenu):
        get_tree().reload_current_scene()
    "alwaysShowMenuOnHomePage", \
    "showLevelCompletionInfoOnMainMenu":
      if global.isAlive(global.mainMenu):
        get_tree().reload_current_scene()
        global.tabMenu.__menu.reloadDataFromFile.call_deferred()
        global.tabMenu.__menu.reloadUi.call_deferred()
    "smallLevelDisplaysInOnlineLevelList", \
    "onlyShowLevelsForCurrentVersion":
      # online level list reload
      if not global.isAlive(global.level) and not not global.isAlive(global.mainMenu):
        get_tree().reload_current_scene()
    "optionMenuToSideOnMainMenuInsteadOfOverlay":
      if global.isAlive(global.mainMenu):
        global.tabMenu.__menu.reloadDataFromFile.call_deferred()
        global.tabMenu.__menu.reloadUi.call_deferred()
        if global.useropts.optionMenuToSideOnMainMenuInsteadOfOverlay:
          var menu = global.mainMenu.optsmenunode.get_node("../../../")
          _visible = false
          menu._visible = true
          menu.__menu.reloadDataFromFile.call_deferred()
          menu.__menu.reloadUi.call_deferred()
        else:
          if not global.useropts.alwaysShowMenuOnHomePage:
            global.tabMenu._visible = true
            _visible = false
          global.tabMenu.__menu.reloadDataFromFile.call_deferred()
          global.tabMenu.__menu.reloadUi.call_deferred()
    "playerRespawnTime":
      if global.isAlive(global.player):
        global.player.DEATH_TIME = max(5, global.useropts.playerRespawnTime)
    _:
      if OS.has_feature("editor"):
        DisplayServer.clipboard_set(thingChanged)
        log.err(thingChanged)

  if thingChanged == "theme" or ftml:
    if global.useropts.theme == 0:
      get_window().theme = null
    else:
      get_window().theme = load("res://themes/" + ["default", "blue", "black"][global.useropts.theme] + "/THEME.tres")
    get_parent().theme = get_window().theme
    RenderingServer.set_default_clear_color(["#4d4d4d", "#4b567aff", "#4d4d4d"][global.useropts.theme])
    if global.isAlive(global.level):
      global.level.save(false)
      global.loadMap.call_deferred(global.mainLevelName, true)

  if waitingForMouseUp: return
  if (thingChanged in ['tabMenuScale']) \
  or global.useropts.alwaysShowMenuOnHomePage \
  or global.useropts.optionMenuToSideOnMainMenuInsteadOfOverlay \
  :
    if Input.is_mouse_button_pressed(MouseButton.MOUSE_BUTTON_LEFT):
      waitingForMouseUp = true
      while Input.is_mouse_button_pressed(MouseButton.MOUSE_BUTTON_LEFT):
        await global.wait(100)
      waitingForMouseUp = false
    updateSize.call_deferred()

func updateSize():
  if !isOptionsMenuOnMainMenu:
    size = Vector2(1152.0, 648.0) / global.useropts.tabMenuScale
    scale = Vector2(global.useropts.tabMenuScale, global.useropts.tabMenuScale)
