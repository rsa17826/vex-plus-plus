@icon("images/1.png")
extends EditorBlock
class_name BlockPath

const SPEED = 150
var maxProgress: float

func generateBlockOpts():
  blockOptions.path = {"default": "1003.0,89.0,562.0,449.0,24.0,266.0,1003.0,89.0",
  "type": global.PromptTypes.string}
  blockOptions.endMode = {
    "default": 0,
    "type": global.PromptTypes._enum,
    "values": ['stop', 'restart', "back"],
  }

var path: Array = []

func getMaxProgress() -> float:
  var total_distance = 0
  for i in range(1, path.size()):
    total_distance += path[i].distance_to(path[i - 1])
  return total_distance

func getPointProgress(idx) -> float:
  if idx < 0 or idx >= path.size():
    return 0
  var point_distance = 0
  for i in range(1, idx + 1):
    point_distance += path[i].distance_to(path[i - 1])
  return point_distance

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

func on_respawn():
  maxProgress = getMaxProgress()
  var p := selectedOptions.path.split(',') as Array
  while p:
    path.append(Vector2(float(p.pop_front()), float(p.pop_front())))

  # log.pp('getMaxProgress: ', getMaxProgress())
  # log.pp('getPointProgress: ', getPointProgress(1))
  # log.pp('getPointProgress: ', getPointProgress(2))
  # log.pp('fromProgressToPoint: ', fromProgressToPoint(2.5))
  # log.pp('fromProgressToPoint: ', fromProgressToPoint(3.6))

  # $Path2D/PathFollow2D.progress = 0
  # scale = Vector2(1, 1)
  # await global.wait()
  # $Path2D.curve = Curve2D.new()
  # var blocks = global.level.get_node("blocks").get_children().filter(func(block):
  #   return block is Node2D \
  #   and block != self \
  #   and block != global.player.get_parent() \
  #   and "root" in block \
  #   and block.pathFollowNode
  #   )
  # log.pp(blocks)
  # var pathinfo = (selectedOptions.path.split(",") as Array).map(func(e):
  #   return float(e))
  # log.pp(pathinfo)
  # var lastPos = null
  # var dist = 0
  # while len(pathinfo):
  #   var pos := Vector2(pathinfo.pop_front(), pathinfo.pop_front())
  #   $Path2D.curve.add_point(pos)
  #   if lastPos != null:
  #     dist += lastPos.distance_to(pos)
  #   log.pp(dist, lastPos)
  #   for block in blocks:
  #     if abs(block.global_position - (pos + position)) < Vector2(10, 10):
  #       blocks.erase(block)
  #       addToPath(block, dist)
  #   lastPos = pos

# func addToPath(block, startDist):
#   log.pp(block)
#   var currentPath = $Path2D/PathFollow2D.duplicate()
#   $Path2D.add_child(currentPath)
#   currentPath.startDist = startDist
#   currentPath.block = block
#   block.reparent(currentPath)
#   block.position = Vector2.ZERO