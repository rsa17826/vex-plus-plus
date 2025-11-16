@icon("images/editorBar.png")
extends EditorBlock
class_name Block10xSpike

func on_respawn():
  # $Node2D.position = Vector2(0, 11-72.5)
  thingThatMoves.position = Vector2.ZERO

func on_body_entered(body: Node2D):
  if body.root is BlockBomb \
  # and body.vel.normal.y > 0 \
  :
    body.root.explode()

func getDeathMessage(message: String, dir: Vector2) -> String:
  match dir:
    Vector2.UP:
      message += "jumped into a spike"
    Vector2.DOWN:
      message += "got popped on a spike"
    Vector2.LEFT, Vector2.RIGHT:
      message += "walked right into a spike"
    Vector2.ZERO:
      message += "got teleported into a spike"
  return message