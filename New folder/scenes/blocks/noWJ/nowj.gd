@icon("images/both.png")
extends EditorBlock
class_name BlockNowj

func on_respawn() -> void:
  thingThatMoves.position = Vector2.ZERO
