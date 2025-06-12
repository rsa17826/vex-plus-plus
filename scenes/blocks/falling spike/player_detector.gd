extends RayCast2D

@export var root: editor

func _physics_process(delta: float) -> void:
  if %playerDetector.is_colliding() \
  and not root.falling \
  and not root.respawnTimer > 0 \
  and not root.respawning \
  :
    root.falling = true
    %"attach detector".following = false