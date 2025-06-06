extends "res://scenes/blocks/editor.gd"

func generateBlockOpts():
  blockOptions.path = {"default": "1003.0,89.0,562.0,449.0,24.0,266.0,1003.0,89.0",
  "type": global.PromptTypes.string}

func on_respawn():
  await global.wait()
  for follower in $Area2D.get_overlapping_areas():
    log.pp(follower.root.id)
    var pathFollow = preload("res://scenes/blocks/path/pf.tscn").instantiate()
    $Path2D.curve = Curve2D.new()
    var pathinfo = (selectedOptions.path.split(",") as Array).map(func(e):
      return float(e))
    while len(pathinfo):
      $Path2D.curve.add_point(Vector2(pathinfo.pop_front(), pathinfo.pop_front()))

    $Path2D.add_child(pathFollow)
    follower.root.reparent(pathFollow)
    # follower.root.global_position = pathFollow.global_position
    # follower.root.position = Vector2.ZERO
    # await global.wait()
    # follower.root.position = Vector2.ZERO