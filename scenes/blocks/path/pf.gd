extends PathFollow2D
var speed = 250.0

func on_respawn():
  progress = 0

func _physics_process(delta: float) -> void:
  progress += delta * speed
  log.pp(progress)