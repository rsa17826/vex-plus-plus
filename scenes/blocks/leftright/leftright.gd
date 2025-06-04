extends "res://scenes/blocks/editor.gd"

@export_group("LEFTRIGHT")
@export var nodeToMove: Node2D

func on_physics_process(delta: float) -> void:
  nodeToMove.global_position.x = startPosition.x - sin(global.tick * 1.5) * 200
