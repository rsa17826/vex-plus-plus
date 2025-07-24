@icon("images/1.png")
extends EditorBlock
class_name BlockPath

const SPEED = 150
var maxProgress: float
const editNodeSpawner = preload("res://scenes/blocks/path/editNode.tscn")

func generateBlockOpts():
  blockOptions.path = {
    "default": "1003.0,89.0,562.0,449.0,24.0,266.0,1003.0,89.0",
    "type": global.PromptTypes.string
  }
  blockOptions.endMode = {
    "default": 0,
    "type": global.PromptTypes._enum,
    "values": ['stop', 'restart', "back"],
  }

var path: Array = []
var pathEditNodes: Array[BlockPath_editNode] = []

func getMaxProgress() -> float:
  var total_distance = 0
  for i in range(1, path.size()):
    total_distance += path[i].distance_to(path[i - 1])
  return total_distance

# func getPointProgress(idx) -> float:
#   if idx < 0 or idx >= path.size():
#     return 0
#   var point_distance = 0
#   for i in range(1, idx + 1):
#     point_distance += path[i].distance_to(path[i - 1])
#   return point_distance

func fromProgressToPoint(prog) -> Vector2:
  var current_distance = 0
  for i in range(1, path.size()):
    var segment_distance = path[i].distance_to(path[i - 1])
    if current_distance + segment_distance >= prog:
      var t = (prog - current_distance) / segment_distance
      return path[i - 1].move_toward(path[i], t * segment_distance)
    current_distance += segment_distance
  return path[path.size() - 1]

func on_physics_process(delta: float) -> void:
  # log.pp(fromProgressToPoint(global.tick * SPEED))
  var currentPointPos = (func():
    match selectedOptions.endMode:
      0: return fromProgressToPoint(global.tick * SPEED)
      1: return fromProgressToPoint(fmod(global.tick * SPEED, maxProgress))
      2:
        var time = fmod(global.tick * SPEED, maxProgress * 2)
        if time <= maxProgress:
          return fromProgressToPoint(time)
        else:
          return fromProgressToPoint(maxProgress - (time - maxProgress))
      _: return Vector2.ZERO
    ).call()
  for child in attach_children:
    child.thingThatMoves.global_position = (
      currentPointPos
      + global_position
      + (child.startPosition - startPosition)
    )

func on_process(delta: float) -> void:
  queue_redraw()

func _draw() -> void:
  var lastPoint = global_position
  for idx in range(len(path)):
    var point = path[idx]
    draw_line(
      to_local(lastPoint),
      to_local(global_position + point),
      global.useropts.pathColor,
      10
    )
    lastPoint = global_position + point

func updatePoint(node: BlockPath_editNode, moveStopped: bool) -> void:
  var idx = pathEditNodes.find(node)
  path[idx + 1] = node.startPosition - global_position
  if moveStopped:
    # remove the Vector2.ZERO from the front
    path.pop_front()
    selectedOptions.path = ','.join(path.map(func(e): return str(e.x) + ',' + str(e.y)))
    # don't know why I need both, ill have to fix this later
    respawn()
    on_respawn()

func on_respawn():
  maxProgress = getMaxProgress()
  var p := selectedOptions.path.split(',') as Array
  # start at the paths location
  path = [Vector2.ZERO]
  for node in pathEditNodes:
    node.queue_free()
  pathEditNodes = []
  while p:
    var newPoint = Vector2(float(p.pop_front()), float(p.pop_front()))
    path.append(newPoint)
    var editNode = editNodeSpawner.instantiate()
    editNode.global_position = newPoint + global_position
    editNode.startPosition = newPoint + global_position
    editNode.path = self
    pathEditNodes.append(editNode)
    global.level.get_node('blocks').add_child(editNode)