extends Control

var containers: Array[FoldableContainer] = []
@export var optsmenunode: Control
@export var alwaysShowMenu: bool = false

var __menu: Menu
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
  if alwaysShowMenu: return
  # var focus = get_viewport().gui_get_focus_owner()
  # if focus is LineEdit or focus is TextEdit: return
  if event is InputEventKey:
    if Input.is_action_just_pressed(&"toggle_tab_menu", true):
      get_viewport().set_input_as_handled()
      visible = !visible
      get_parent().visible = visible
      if visible:
        Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func _ready() -> void:
  if alwaysShowMenu:
    visible = true
    get_parent().visible = true
  else:
    global.overlays.append(self )
    get_parent().visible = false
    visible = false
    global.tabMenu = self
  var data = global.file.read("res://scenes/main menu/userOptsMenu.jsonc")
  __menu = Menu.new(optsmenunode)
  __menu.onchanged.connect(updateUserOpts)
  for thing in data:
    __loadOptions(thing)

  __menu.startGroup("open in explorer")
  __menu.add_button("open editorBar.sds", func():
    OS.shell_open(global.path.abs("res://editorBar.sds"))
  )
  __menu.add_button("open current level folder", func():
    if global.mainLevelName and global.isAlive(global.level):
      OS.shell_open(global.path.abs("res://maps/" + global.mainLevelName))
    else:
      OS.shell_open(global.path.abs("res://maps"))
  )
  __menu.endGroup()
  __menu.show_menu()
  updateUserOpts()
  updateSize()
  # var node_stack: Array[Node] = [ self ]
  # while not node_stack.is_empty():
  #   var node: Node = node_stack.pop_back()
  #   if is_instance_valid(node):
  #     if "transparent_bg" in node:
  #       node.transparent_bg = true
  #     if node is Control and node.get_parent() is CanvasLayer:
  #       node.theme = get_window().theme
  #     node_stack.append_array(node.get_children())

# func loadaUserOptions() -> void:
#   var data = global.file.read("res://scenes/main menu/userOptsMenu.jsonc")
#   __menu = Menu.new(optsmenunode)
#   __menu.onchanged.connect(updateUserOpts)
#   for thing in data:
#     __loadOptions(thing)
#   __menu.show_menu()
#   scrollContainer.set_deferred('scroll_vertical', int(global.file.read("user://scrollContainerscroll_vertical", false, "0")))
#   scrollContainer.gui_input.connect(func(event):
#     # scroll up or down then save scroll position
#     if event.button_mask == 8 || event.button_mask == 16:
#       global.file.write("user://scrollContainerscroll_vertical", str(scrollContainer.scroll_vertical), false))
#   updateUserOpts()

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
    "showHoveredBlocksList", \
    "selectedBlockFormatString", \
    "hoveredBlockFormatString", \
    "showSignalListInEditor", \
    "showSignalListInPlay", \
    "showSignalConnectionLinesOnHover", \
    "showSignalConnectionLinesInEditor", \
    "showSignalConnectionLinesInPlay", \
    "onlyShowSignalConnectionsIfHoveringOverAny", \
    "showLevelModsWhileEditing", \
    "showLevelModsWhilePlaying", \
    "showLevelLoadingProgressBar", \
    "showLevelLoadingBehindProgressBar", \
    "showPathBlockInPlay", \
    "showPathLineInPlay", \
    "showPathEditNodesInPlay", \
    "playerRespawnTime", \
    "defaultCreatorName", \
    "defaultCreatorNameIsLoggedInUsersName", \
    "loadOnlineLevelListOnSceneLoad", \
    "slowTime", \
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
      __menu.reload()
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
    "editorBarBlockSize", \
    "editorBarOffset", \
    "editorBarPosition", \
    "showEditorBarBlockMissingErrors", \
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
    "smallLevelDisplaysInLocalLevelList", \
    "showMenuOnHomePage":
      if global.isAlive(global.mainMenu):
        get_tree().reload_current_scene()
    "smallLevelDisplaysInOnlineLevelList", \
    "onlyShowLevelsForCurrentVersion":
      # online level list reload
      if not global.isAlive(global.level) and not not global.isAlive(global.mainMenu):
        get_tree().reload_current_scene()
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
  if thingChanged in ['tabMenuScale']:
    if Input.is_mouse_button_pressed(MouseButton.MOUSE_BUTTON_LEFT):
      waitingForMouseUp = true
      while Input.is_mouse_button_pressed(MouseButton.MOUSE_BUTTON_LEFT):
        await global.wait(100)
      waitingForMouseUp = false
    updateSize.call_deferred()

func updateSize():
  if !alwaysShowMenu:
    size = Vector2(1152.0, 648.0) / global.useropts.tabMenuScale
    scale = Vector2(global.useropts.tabMenuScale, global.useropts.tabMenuScale)
