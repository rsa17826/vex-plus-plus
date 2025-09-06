extends RayCast2D

@export var root: EditorBlock

func _physics_process(delta: float) -> void:
  if is_colliding() and not root.respawning and not root.onCooldown:
    root.playerDetected()