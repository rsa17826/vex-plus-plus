extends Node2D

# func _ready() -> void:
#   loadLevel(global.currentLevel().name)
func _init() -> void:
  global.level = self

@export var boxSelectDrawingNode: Control

func onProgress(prog, max):
  if !is_instance_valid(global.ui): return
  if !is_instance_valid(global.ui.progressBar): return
  global.ui.progressBar.max_value = max
  global.ui.progressBar.value = prog
  if prog % 150 == 0:
    await global.wait()

func loadLevel(level):
  if !is_instance_valid(global.ui): return
  if !is_instance_valid(global.ui.progressBar): return
  # await global.wait()
  global.stopTicking = true
  global.tick = 0
  global.hoveredBlocks = []
  global.player.state = global.player.States.levelLoading

  global.ui.modifiers.updateUi(global.currentLevelSettings())
  global.ui.modifiers.loadModsToPlayer()
  global.activeSignals = {}
  global.ui.progressContainer.visible = true
  var leveldata = await (sds.loadDataFromFileSlow if global.useropts.showLevelLoadingProgressBar else sds.loadDataFromFile) \
  .call(global.path.join(global.levelFolderPath, level + '.sds'),
    [
      {"x": 0, "y": - 65},
      {"h": 1, "id": "basic", "r": 0.0, "w": 1, "x": 0, "y": 0}
    ],
    func(prog, max):
      if !is_instance_valid(global.ui): return
      if !is_instance_valid(global.ui.progressBar): return
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
  if !is_instance_valid(global.ui): return
  if !is_instance_valid(global.ui.progressBar): return
  for node in children:
    if global.isAlive(node):
      node.queue_free()
    else:
      log.err("node already freed", children)
    if global.useropts.showLevelLoadingProgressBar:
      prog += 1
      await onProgress(prog, max)
  global.player.root.global_position = Vector2(leveldata[0].x, leveldata[0].y)
  global.player.global_position = Vector2(leveldata[0].x, leveldata[0].y)
  global.player.root.startPosition = Vector2(leveldata[0].x, leveldata[0].y)
  var invalidBlockErrors := {}
  for thing in leveldata.slice(1):
    if !ResourceLoader.exists("res://scenes/blocks/" + thing.id + "/main.tscn"):
      if thing.id not in invalidBlockErrors:
        invalidBlockErrors[thing.id] = 0
      invalidBlockErrors[thing.id] += 1
      if not 'options' in thing:
        thing.options = {}
      thing.options.fakeId = thing.id
      thing.id = "UNAVAILABLE"
    $blocks.add_child(global.createNewBlock(thing))
    if global.useropts.showLevelLoadingProgressBar:
      prog += 1
      await onProgress(prog, max)
  for thing in invalidBlockErrors:
    log.err("Invalid block: \n\"" + thing + '"\n used "' + str(invalidBlockErrors[thing]) + "\" times")
  global.editorBar._ready()
  await global.wait()
  global.tick = 0
  global.stopTicking = false
  global.ui.progressContainer.visible = false
  global.player.state = global.player.States.falling
  # global.player.updateCollidingBlocksEntered()
  await global.wait()
  global.tick = global.currentLevel().tick

  # await global.wait()
  # await global.wait(300)
  # global.savePlayerLevelData()
  # await global.wait()
  # global.player.die(0, false, true)
  # global.player.deathPosition = global.player.lastSpawnPoint
var saving := false
var grabbingImage := false

func save(saveImage: bool):
  if global.ctrlMenuVisible: return
  if saving:
    ToastParty.err("already saving")
    return
  saving = true
  global.ui.levelSaved.texture = preload("res://scenes/ui/images/game saved.webp")
  if !len($blocks.get_children()):
    log.err("nothing to save")
    return
  if global.useropts.showIconOnSave:
    global.ui.levelSaved.visible = true
  global.ui.levelSaved.modulate.a = .2

  var data: Array = [
    {
      "x": global.player.root.startPosition.x,
      "y": global.player.root.startPosition.y
    },
  ]
  for child in $blocks.get_children():
    if child.DONT_SAVE: continue
    var obj = {
      "x": child.startPosition.x,
      "y": child.startPosition.y,
      "w": (child.startScale.x * 7.0),
      "h": (child.startScale.y * 7.0),
      "r": child.startRotation_degrees,
      "id": str(child.id),
    }
    if child.normalScale:
      obj.w = child.startScale.x
      obj.h = child.startScale.y

    if child.selectedOptions:
      obj.options = child.selectedOptions.duplicate()
    if child.id == "UNAVAILABLE":
      obj.id = child.selectedOptions.fakeId
      if 'options' in obj:
        obj.options.erase("fakeId")
    data.append(obj)
  log.pp(global.path.join(global.levelFolderPath, global.currentLevel().name + ".sds"))
  sds.saveDataToFile(global.path.join(global.levelFolderPath, global.currentLevel().name + ".sds"), data)
  var opts = sds.loadDataFromFile(global.path.join(global.levelFolderPath, "options.sds"))
  opts.gameVersion = int(global.file.read("res://VERSION", false, "-1"))
  opts.levelVersion = opts.levelVersion + 1 if 'levelVersion' in opts else 1
  if saveImage:
    grabbingImage = true
    var lastTick = global.tick
    var laststopTicking = global.stopTicking
    global.tick = 0
    var arr = []
    for child: EditorBlock in $blocks.get_children():
      child.respawning = 3
      arr.append([child.global_position, child.rotation_degrees])
      child.global_position = child.startPosition
      child.rotation_degrees = child.startRotation_degrees
    await RenderingServer.frame_post_draw
    var image = global.ui.overlayRemovalHidersubViewportContainer.get_node("SubViewport").get_texture().get_image()
    grabbingImage = false
    var minSize = min(image.get_width(), image.get_height())
    var maxSize = max(image.get_width(), image.get_height())
    var rect = image.get_used_rect()
    if image.get_width() > image.get_height():
      rect.position.x = (maxSize - minSize) / 2
      rect.position.y = 0
    else:
      rect.position.y = (maxSize - minSize) / 2
      rect.position.x = 0
    rect.size.x = minSize
    rect.size.y = minSize
    image = image.get_region(rect)
    image.resize(292, 292)
    image.convert(Image.FORMAT_RGBA8)
    # for x in range(image.get_width()):
    #   for y in range(image.get_height()):
    #     var current_color = image.get_pixel(x, y)
    #     if current_color in [Color("#4B567A"), Color("#4D4D4D")]:
    #       image.set_pixel(x, y, Color.TRANSPARENT)
    image.save_png(global.path.join(global.levelFolderPath, "image.png"))
    sds.saveDataToFile(global.path.join(global.levelFolderPath, "options.sds"), opts)
    var i = 0
    for child: EditorBlock in $blocks.get_children():
      child.respawning = 0
      child.global_position = arr[i][0]
      child.rotation_degrees = arr[i][1]
      i += 1
    global.stopTicking = laststopTicking
    global.tick = lastTick
    global.ui.levelSaved.texture = ImageTexture.create_from_image(image)
  global.ui.levelSaved.modulate.a = 1
  if saveImage:
    await global.wait(1000)
  global.ui.levelSaved.visible = false
  saving = false
