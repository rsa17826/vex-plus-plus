extends "res://scenes/blocks/editor.gd"

@export_group("ROTATING BUZSAW")
@export var nodeToSpin: Node2D
func on_physics_process(delta: float) -> void:
  spin(300, nodeToSpin)