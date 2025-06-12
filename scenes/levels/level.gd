extends Node2D

# @name same line return
# @regex :\s*return(\s*.{0,10})$
# @replace : return$1
# @flags gm
# @endregex

# func _ready() -> void:
#   loadLevel(global.currentLevel().name)
func _init() -> void:
  global.level = self

func onProgress(prog, max):
  global.ui.progressBar.max_value = max
  global.ui.progressBar.value = prog
  if prog % 50 == 0:
    await global.wait(150)

func loadLevel(level):
  # await global.wait()
  global.stopTicking = true
  global.tick = 0
  global.hoveredBlocks = []
  global.player.state = global.player.States.levelLoading
  # global.levelColor = int(global.levelOpts.stages[global.currentLevel().name].color)
  # log.pp(global.path.join(global.levelFolderPath, level), global.loadedLevels, global.beatLevels)
  global.ui.progressContainer.visible = true
  var leveldata = await (sds.loadDataFromFileSlow if global.useropts.showLevelLoadingProgressBar else sds.loadDataFromFile) \
  .call(global.path.join(global.levelFolderPath, level + '.sds'),
    [
      {"x": 0, "y": 0},
      {"h": 1, "id": "basic", "r": 0.0, "w": 1, "x": 0, "y": 65}
    ],
    func(prog, max):
      global.ui.progressBar.max_value=max
      global.ui.progressBar.value=prog
  )
  var prog = 0
  var children = $blocks.get_children()
  var max = len(children) + len(leveldata) - 1
  if global.useropts.showLevelLoadingProgressBar:
    global.ui.progressContainer.get_node("levelHider").visible = !global.useropts.showLevelLoadingBehindProgressBar
  if !leveldata: return
  # global.ui.progressContainer.text = "Loading Level..."
  for node in children:
    $blocks.remove_child(node)
    if global.useropts.showLevelLoadingProgressBar:
      prog += 1
      await onProgress(prog, max)
  global.player.get_parent().global_position = Vector2(leveldata[0]['x'], leveldata[0]['y'])
  global.player.global_position = Vector2(leveldata[0]['x'], leveldata[0]['y'])
  global.player.get_parent().startPosition = Vector2(leveldata[0]['x'], leveldata[0]['y'])
  for thing in leveldata.slice(1):
    createBlock(thing['id'], thing['x'], thing['y'], thing['w'], thing['h'], thing['r'], thing['options'] if 'options' in thing else 0)
    if global.useropts.showLevelLoadingProgressBar:
      prog += 1
      await onProgress(prog, max)
  
  global.player.floor_constant_speed = !global.currentLevelSettings("changeSpeedOnSlopes")
  global.player.get_node("../CanvasLayer/editor bar")._ready()
  await global.wait()
  global.tick = 0
  for block in $blocks.get_children():
    block.respawn()
  global.stopTicking = false
  global.ui.progressContainer.visible = false
  global.player.state = global.player.States.falling
  global.player.updateCollidingBlocksEntered()
  # await global.wait()
  # await global.wait(300)
  # global.savePlayerLevelData()
  # await global.wait()
  # global.player.die(0, false)
  # global.player.deathPosition = global.player.lastSpawnPoint

func createBlock(id, x, y, w, h, r, options):
  if load("res://scenes/blocks/" + id + "/main.tscn"):
    var thing = load("res://scenes/blocks/" + id + "/main.tscn").instantiate()
    thing.startPosition = Vector2(x, y)
    thing.position = Vector2(x, y)
    thing.startScale = Vector2(w / 7.0, h / 7.0)
    thing.scale = Vector2(w / 7.0, h / 7.0)
    thing.startRotation_degrees = r
    thing.rotation_degrees = r
    thing.id = id
    if options:
      thing.selectedOptions = options
    $blocks.add_child(thing)
  else:
    log.err("Error loading block", id)

func save():
  if global.useropts.showIconOnSave:
    global.ui.levelSaved.visible = true
  global.ui.levelSaved.modulate.a = .2

  var data: Array = [
    {
      "x": global.player.get_parent().startPosition.x,
      "y": global.player.get_parent().startPosition.y
    },
  ]
  for child in $blocks.get_children():
    var obj = {
      "x": child.startPosition.x,
      "y": child.startPosition.y,
      "w": (child.startScale.x * 7.0),
      "h": (child.startScale.y * 7.0),
      "r": child.startRotation_degrees,
      "id": str(child.id),
    }
    if child.selectedOptions:
      obj["options"] = child.selectedOptions
    data.append(obj)
  log.pp(global.path.join(global.levelFolderPath, global.currentLevel().name + ".sds"))
  sds.saveDataToFile(global.path.join(global.levelFolderPath, global.currentLevel().name + ".sds"), data)
  var opts = sds.loadDataFromFile(global.path.join(global.levelFolderPath, "options.sds"))
  opts.version = int(global.file.read("res://VERSION", false, "-1"))
  sds.saveDataToFile(global.path.join(global.levelFolderPath, "options.sds"), opts)
  global.ui.levelSaved.modulate.a = 1
  await global.wait(1000)
  global.ui.levelSaved.visible = false
