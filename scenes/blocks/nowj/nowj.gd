@icon("images/both.png")
extends EditorBlock
class_name BlockNowj

func _init() -> void:
  mouseRotationOffset = 180

func on_respawn() -> void:
  thingThatMoves.position = Vector2.ZERO
