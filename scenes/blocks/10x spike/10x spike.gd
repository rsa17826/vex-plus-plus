@icon("images/1.png")
extends EditorBlock
class_name Block10xSpike

func on_respawn():
  $Node2D.position = Vector2(0, 6)
  thingThatMoves.position = Vector2.ZERO