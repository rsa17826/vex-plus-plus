extends EditorBlock
class_name BlockLaser_Projectile

const speed = 300

func on_ready():
  global.player.OnPlayerDied.connect(queue_free)

func on_physics_process(delta: float) -> void:
  position += (Vector2.LEFT * delta * speed * scale).rotated(rotation)

func on_body_entered(body: Node2D) -> void:
  if body is Player: return
  if body.root is BlockBomb:
    body.root.explode()
  queue_free()