extends RayCast2D

@export var root: EditorBlock

func on_physics_process(delta: float) -> void:
  if is_colliding() and not root.respawning and not root.onCooldown and get_parent() in root.spikesToClone:
    root.playerDetected()