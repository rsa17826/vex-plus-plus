@icon("images/editorBar.png")
extends EditorBlock
class_name Block10xOnewaySpike

func on_respawn():
  # $Node2D.position = Vector2(0, 11-72.5)
  thingThatMoves.position = Vector2.ZERO

func on_body_entered(body: Node2D):
  if body.root is BlockBomb \
  # and body.vel.normal.y > 0 \
  :
    body.root.explode()