@icon("images/editorBar.png")
extends EditorBlock
class_name BlockMovingSpike
func on_respawn():
  thingThatMoves.position = Vector2.ZERO
