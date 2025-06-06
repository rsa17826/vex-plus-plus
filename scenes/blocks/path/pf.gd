extends PathFollow2D
var speed = 200.0
func _physics_process(delta: float) -> void:
  progress += delta * speed
  rotates = false
  log.pp(progress)