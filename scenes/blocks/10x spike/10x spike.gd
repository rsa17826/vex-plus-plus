@icon("images/editorBar.png")
extends EditorBlock
class_name Block10xSpike

func on_respawn():
  # $Node2D.position = Vector2(0, 11-72.5)
  thingThatMoves.position = Vector2.ZERO