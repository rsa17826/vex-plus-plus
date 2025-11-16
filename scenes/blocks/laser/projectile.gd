@icon("images/projectile.png")
extends EditorBlock
class_name BlockLaser_Projectile

const speed = 300

func on_physics_process(delta: float) -> void:
  position += (Vector2.LEFT * delta * speed * scale).rotated(rotation)

func on_body_entered(body: Node2D) -> void:
  if body is Player: return
  if body.root is BlockCrumbling:
    body.root.start()
  if body.root is BlockBomb:
    body.root.explode()
  queue_free.call_deferred()

func getDeathMessage(message: String, dir: Vector2) -> String:
  match dir:
    Vector2.UP:
      message += "jumped into a laser beam"
    Vector2.DOWN:
      message += "fell onto a laser beam"
    Vector2.LEFT, Vector2.RIGHT:
      message += "walked into a laser beam"
    Vector2.ZERO:
      message += "got vaporized by a laser beam"
  return message