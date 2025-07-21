extends GridContainer

var bgPadding = 5

func _process(delta: float) -> void:
  if global.useropts.showLevelModsWhilePlaying and !global.showEditorUi:
    visible = true
  elif global.useropts.showLevelModsWhileEditing and global.showEditorUi:
    visible = true
  else:
    visible = false

func modVis(mod, val):
  get_node(mod).visible = val

var currentLevelSettings: Dictionary

var editorOpen := false

func toggleEditor():
  editorOpen = !editorOpen
  if editorOpen:
    updateUi(global.player.levelFlags, true)
    global.ui.modifiersEditorBg.visible = true
    global.ui.modifiersEditorBg.size = size + Vector2(bgPadding, bgPadding) * 2
    global.ui.modifiersEditorBg.global_position = global_position - Vector2(bgPadding, bgPadding)
    global.ui.modifiersEditorBg.color = Color.hex(global.useropts.modifierEditorBgColor)
  else:
    global.ui.modifiersEditorBg.visible = false
    updateUi(global.player.levelFlags)

func updateUi(
  data: Dictionary,
  showAllMods: bool = global.useropts.showUnchangedLevelMods
):
  currentLevelSettings = data
  # hide all mods
  for child in get_children():
    if child.name == '_base': continue
    child.visible = showAllMods

  for k in data:
    var v = data[k]
    match typeof(v):
      TYPE_BOOL:
        if showAllMods:
          modVis(k, true)
          modVis(k + '/nope', !v)
        else:
          if v == global.defaultLevelSettings[k]:
            modVis(k, false)
          else:
            modVis(k, true)
            modVis(k + '/nope', !v)
      _:
        match k:
          'jumpCount':
            for child in get_node('jumpCount').get_children():
              child.visible = false
            modVis('jumpCount', true)
            if v >= 4:
              modVis('jumpCount/4+', true)
            elif v == 1:
              modVis('jumpCount/1', true)
              modVis('jumpCount', showAllMods)
            elif v <= 0:
              modVis('jumpCount/1', true)
              modVis('jumpCount/nope', true)
            else:
              modVis('jumpCount/' + str(v), true)
          "color":
            pass
          _:
            log.err('updateUi: unknown key:', k, v)
            breakpoint

func loadModsToPlayer():
  for child in get_children():
    if child.name == '_base': continue
    global.player.levelFlags[child.name] = currentLevelSettings[child.name]
    
  global.player.floor_constant_speed = !currentLevelSettings.changeSpeedOnSlopes
  global.player.MAX_JUMP_COUNT = currentLevelSettings.jumpCount

func _on_gui_input(event: InputEvent, source: Control) -> void:
  if !global.ui.modifiers.editorOpen: return
  if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_LEFT:
    var flag = source.name
    var type = (func():
      match typeof(global.player.levelFlags[flag]):
        TYPE_INT: return global.PromptTypes.int
        TYPE_FLOAT: return global.PromptTypes.float
        TYPE_STRING: return global.PromptTypes.string
        TYPE_BOOL: return global.PromptTypes.bool
        _: log.err(type_string(typeof(global.player.levelFlags[flag])), flag)
    ).call()
    global.player.levelFlags[flag] = await global.prompt(
      flag,
      type,
      global.player.levelFlags[flag],
      global.defaultLevelSettings[flag]
    )
    updateUi(global.player.levelFlags, true)
    loadModsToPlayer()
    saveModsToFile()

func saveModsToFile():
  var f = global.path.join(
    global.MAP_FOLDER,
    global.mainLevelName,
    "/options.sds"
  )
  var data = sds.loadDataFromFile(f)
  data.stages[global.currentLevel().name] = currentLevelSettings
  sds.saveDataToFile(
    f,
    data
  )