extends GridContainer

func _process(delta: float) -> void:
  if global.useropts.showLevelModsWhilePlaying and !global.showEditorUi:
    visible = true
  elif global.useropts.showLevelModsWhileEditing and global.showEditorUi:
    visible = true
  else:
    visible = false

func modVis(mod, val):
  get_node(mod).visible = val

var currentLevelSettings: Dictionary[String, Variant]

func updateUi(
  data: Dictionary[String, Variant],
  showAllMods: bool = global.useropts.showUnchangedLevelMods
):
  currentLevelSettings = data
  # hide all mods
  for child in get_children():
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
              modVis('jumpCount', showAllMods)
            elif v <= 0:
              modVis('jumpCount/1', true)
              modVis('jumpCount/nope', true)
            else:
              modVis('jumpCount/' + str(v), true)
          _:
            log.err('updateUi: unknown key:', k, v)
            breakpoint
    log.pp(k, v)

func loadModsToPLayer():
  for child in get_children():
    global.player.levelFlags[child.name] = currentLevelSettings[child.name]
    
  global.player.floor_constant_speed = !currentLevelSettings["changeSpeedOnSlopes"]
  global.player.MAX_JUMP_COUNT = currentLevelSettings["jumpCount"]