extends "res://scenes/blocks/editor.gd"

func generateBlockOpts():
  blockOptions.path = {"default": "1003.0,89.0,562.0,449.0,24.0,266.0,1003.0,89.0",
  "type": global.PromptTypes.string}

func on_respawn():
  await global.wait()
  # for follower in $Area2D.get_overlapping_areas():
  #   log.pp(block.id)
  $Path2D.curve = Curve2D.new()
  var pathinfo = (selectedOptions.path.split(",") as Array).map(func(e):
    return float(e))
  log.pp(pathinfo)
  while len(pathinfo):
    var pos = Vector2(pathinfo.pop_front(), pathinfo.pop_front())
    $Path2D.curve.add_point(pos)
    for block in global.level.get_children():
      if block == self: return
      if not block is Node2D: return
      if block.global_position == pos:
        addToPath(block)

func addToPath(block):
  block.curve = $Path2D.curve
  var pathFollow = preload("res://scenes/blocks/path/pf.tscn").instantiate()
  $Path2D.add_child(pathFollow)
  block.reparent(pathFollow)
  # block.global_position = pathFollow.global_position
  block.position = Vector2.ZERO
  await global.wait()
  block.position = Vector2.ZERO