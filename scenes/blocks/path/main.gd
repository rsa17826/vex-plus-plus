extends "res://scenes/blocks/editor.gd"

func generateBlockOpts():
  blockOptions.path = {"default": "1003.0,89.0,562.0,449.0,24.0,266.0,1003.0,89.0",
  "type": global.PromptTypes.string}

func on_respawn():
  $Path2D/PathFollow2D.progress = 0
  scale = Vector2(1, 1)
  await global.wait()
  # for follower in $Area2D.get_overlapping_areas():
  #   log.pp(block.id)
  $Path2D.curve = Curve2D.new()
  var blocks = global.level.get_node("blocks").get_children().filter(func(block):
    return block is Node2D \
    and block != self \
    and block != global.player.get_parent() \
    and "root" in block \
    and block.pathFollowNode
    )
  log.pp(blocks)
  var pathinfo = (selectedOptions.path.split(",") as Array).map(func(e):
    return float(e))
  log.pp(pathinfo)
  var lastPos = null
  var dist = 0
  while len(pathinfo):
    var pos := Vector2(pathinfo.pop_front(), pathinfo.pop_front())
    $Path2D.curve.add_point(pos)
    if lastPos != null:
      dist += lastPos.distance_to(pos)
    log.pp(dist, lastPos)
    for block in blocks:
      if abs(block.global_position - (pos + position)) < Vector2(10, 10):
        blocks.erase(block)
        addToPath(block, dist)
    lastPos = pos

func addToPath(block, startDist):
  log.pp(block)
  var currentPath = $Path2D/PathFollow2D.duplicate()
  $Path2D.add_child(currentPath)
  currentPath.startDist = startDist
  currentPath.block = block
  block.reparent(currentPath)
  block.position = Vector2.ZERO