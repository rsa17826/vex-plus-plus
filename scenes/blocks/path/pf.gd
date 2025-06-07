extends PathFollow2D
var speed = 20000.0

var startDist = 0
var block: Node2D

func _physics_process(delta: float) -> void:
  if not block: return
  block.position = Vector2.ZERO
  # var start = block.global_position
  progress = startDist + (global.tick * (delta * speed))
  # block.lastMovementStep = block.global_position - start