extends EditorBlock

func generateBlockOpts():
  blockOptions.path = {"default": "1003.0,89.0,562.0,449.0,24.0,266.0,1003.0,89.0",
  "type": global.PromptTypes.string}

var path = [
  Vector2(0, 0),
  Vector2(1, 1),
  Vector2(2, 3),
]

func getMaxProgress():
  var total_distance = 0
  for i in range(1, path.size()):
    total_distance += path[i].distance_to(path[i - 1])
  return total_distance

func getPointProgress(idx):
  if idx < 0 or idx >= path.size():
    return 0
  var point_distance = 0
  for i in range(1, idx + 1):
    point_distance += path[i].distance_to(path[i - 1])
  return point_distance

func progressToPoint(prog):
  var current_distance = 0
  for i in range(1, path.size()):
    var segment_distance = path[i].distance_to(path[i - 1])
    if current_distance + segment_distance >= prog:
      var t = (prog - current_distance) / segment_distance
      return path[i - 1].move_toward(path[i], t * segment_distance)
    current_distance += segment_distance
  return path[path.size() - 1]

func on_respawn():
  log.pp('getMaxProgress: ', getMaxProgress())
  log.pp('getPointProgress: ', getPointProgress(1))
  log.pp('getPointProgress: ', getPointProgress(2))
  log.pp('progressToPoint: ', progressToPoint(2.5))
  log.pp('progressToPoint: ', progressToPoint(3.6))

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