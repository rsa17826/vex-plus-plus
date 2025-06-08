extends "res://scenes/blocks/editor.gd"

func on_respawn() -> void:
  $collisionNode.position = Vector2.ZERO
