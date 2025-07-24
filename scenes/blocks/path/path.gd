@icon("images/1.png")
extends EditorBlock
class_name BlockPath

const SPEED = 150

func generateBlockOpts():
  blockOptions.path = {"default": "1003.0,89.0,562.0,449.0,24.0,266.0,1003.0,89.0",
  "type": global.PromptTypes.string}

var path = [
  50 * Vector2(0, 0),
  50 * Vector2(1, 1),
  50 * Vector2(2, 3),
  50 * Vector2(-5, 3),
]

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
  log.pp(fromProgressToPoint(global.tick * SPEED))
  global.player.global_position = fromProgressToPoint(global.tick * SPEED) + global_position
  global.player.vel.user = Vector2.ZERO

func on_respawn():
  log.pp('getMaxProgress: ', getMaxProgress())
  log.pp('getPointProgress: ', getPointProgress(1))
  log.pp('getPointProgress: ', getPointProgress(2))
  log.pp('fromProgressToPoint: ', fromProgressToPoint(2.5))
  log.pp('fromProgressToPoint: ', fromProgressToPoint(3.6))

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