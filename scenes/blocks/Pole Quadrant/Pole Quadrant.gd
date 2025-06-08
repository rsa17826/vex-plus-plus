extends "res://scenes/blocks/editor.gd"

func on_respawn() -> void:
  $collisionNode.position = Vector2.ZERO

func on_physics_process(delta: float) -> void:
  spin(150, $collisionNode)