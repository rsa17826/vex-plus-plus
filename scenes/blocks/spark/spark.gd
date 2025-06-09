extends "res://scenes/blocks/editor.gd"

@export_group("SPARK")
@export var sparkNode: Node2D

func on_physics_process(delta: float) -> void:
  var target = Vector2(0, -1)
  sparkNode.position = target
