extends "res://scenes/blocks/editor.gd"

@export_group("QUADRANT")
@export var QUADRANT_nodeToSpin: Node2D

func on_physics_process(delta: float) -> void:
  spin(150, QUADRANT_nodeToSpin)