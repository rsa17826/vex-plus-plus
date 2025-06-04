extends RayCast2D

@export var root: Node2D

func _physics_process(delta: float) -> void:
  if %playerDetector.is_colliding():
    root.FALLING_SPIKE_falling = true