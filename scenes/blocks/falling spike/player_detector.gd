extends RayCast2D

@export var root: Node2D

func _physics_process(delta: float) -> void:
  if %playerDetector.is_colliding():
    root.falling = true
    %"attach detector".clearAllGroups()