@icon("images/1.png")
extends EditorBlock
class_name BlockStickyFloor

func on_respawn() -> void:
  thingThatMoves.position = Vector2.ZERO
