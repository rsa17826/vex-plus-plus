extends EditorBlock
class_name BlockLaser_Projectile

const speed = 300

func on_ready():
  global.player.OnPlayerDied.connect(queue_free)

func on_physics_process(delta: float) -> void:
  position += (Vector2.LEFT * delta * speed).rotated(rotation)

func on_body_entered(body: Node2D) -> void:
  if not (body is Player):
    queue_free()