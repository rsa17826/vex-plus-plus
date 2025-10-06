extends Control

var bgPadding = 5

func _ready() -> void:
  global.overlays.append(self )

func _process(delta: float) -> void:
  if global.useropts.showLevelModsWhilePlaying and !global.showEditorUi:
    visible = true
  elif global.useropts.showLevelModsWhileEditing and global.showEditorUi:
    visible = true
  else:
    visible = false

func modVis(mod, val):
  $GridContainer.get_node(mod).visible = val

var editorOpen := false

func toggleEditor():
  editorOpen = !editorOpen
  if editorOpen:
    updateUi(global.currentLevelSettings(), true)
    $"modifiers editor bg".visible = true
    $"modifiers editor bg".size = $GridContainer.size + Vector2(bgPadding, bgPadding) * 2
    $"modifiers editor bg".global_position = global_position - Vector2(bgPadding, bgPadding)
  else:
    $"modifiers editor bg".visible = false
    updateUi(global.currentLevelSettings())

func updateUi(
  data: Dictionary,
  showAllMods: bool = global.useropts.showUnchangedLevelMods
):
  # hide all mods
  for child in $GridContainer.get_children():
    if child.name == '_base': continue
    child.visible = showAllMods

  for k in data:
    if k not in global.defaultLevelSettings: continue
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
            for child in $GridContainer.get_node('jumpCount').get_children():
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
          "color": pass
          _:
            log.err('updateUi: unknown key:', k, v)
            breakpoint

func _on_gui_input(event: InputEvent, source: Control) -> void:
  if !global.ui.modifiers.editorOpen: return
  if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_LEFT:
    var levelSettings = global.currentLevelSettings()
    var flag = source.name
    var type = (func():
      match typeof(levelSettings[flag]):
        TYPE_INT: return global.PromptTypes.int
        TYPE_FLOAT: return global.PromptTypes.float
        TYPE_STRING: return global.PromptTypes.string
        TYPE_BOOL: return global.PromptTypes.bool
        _: log.err(type_string(typeof(levelSettings[flag])), flag)
    ).call()
    levelSettings[flag] = await global.prompt(
      flag,
      type,
      levelSettings[flag],
      global.defaultLevelSettings[flag]
    )
    # for child in $GridContainer.get_children():
    #   if child.name == '_base': continue
    #   levelSettings[child.name] = levelSettings[child.name]
    updateUi(levelSettings, true)
    saveData(levelSettings)
func saveData(levelSettings):
  var f = global.path.join(
    global.MAP_FOLDER,
    global.mainLevelName,
    "/options.sds"
  )
  var data = sds.loadDataFromFile(f)
  var startData = global.levelOpts.stages[global.currentLevel().name].duplicate_deep()
  levelSettings = startData.merged(levelSettings, true)
  data.stages[global.currentLevel().name] = levelSettings
  global.levelOpts.stages[global.currentLevel().name] = levelSettings
  global.player.floor_constant_speed = !levelSettings.changeSpeedOnSlopes
  global.player.MAX_JUMP_COUNT = levelSettings.jumpCount
  sds.saveDataToFile(
    f,
    data
  )
