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

func loadLevel(level):
  # await global.wait()
  global.hoveredBlocks = []
  # global.levelColor = int(global.levelOpts.stages[global.currentLevel().name].color)
  # log.pp(global.path.join(global.levelFolderPath, level), global.loadedLevels, global.beatLevels)
  var leveldata = sds.loadDataFromFile(global.path.join(global.levelFolderPath, level + '.sds'), [ {"x": 0, "y": 0}, {"h": 1, "id": "basic", "r": 0.0, "w": 1, "x": 0, "y": 65}])
  if !leveldata: return
  for node in $blocks.get_children():
    $blocks.remove_child(node)
  global.player.get_parent().global_position = Vector2(leveldata[0]['x'], leveldata[0]['y'])
  global.player.global_position = Vector2(leveldata[0]['x'], leveldata[0]['y'])
  global.player.get_parent().startPosition = Vector2(leveldata[0]['x'], leveldata[0]['y'])
  for thing in leveldata.slice(1):
    createBlock(thing['id'], thing['x'], thing['y'], thing['w'], thing['h'], thing['r'], thing['options'] if 'options' in thing else 0)

  global.tick = 0
  global.player.floor_constant_speed = !global.currentLevelSettings("changeSpeedOnSlopes")
  global.player.get_node("../CanvasLayer/editor bar")._ready()
  # await global.wait()
  # await global.wait(300)
  # global.savePlayerLevelData()
  # await global.wait()
  # global.player.die(0, false)
  # global.player.deathPosition = global.player.lastSpawnPoint

func createBlock(id, x, y, w, h, r, options):
  global.tick = 0
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
  global.tick = 0

func save():
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
  log.pp(data)
  sds.saveDataToFile(global.path.join(global.levelFolderPath, global.currentLevel().name + ".sds"), data)
  return data
