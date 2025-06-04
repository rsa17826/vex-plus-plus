extends "res://scenes/blocks/editor.gd"

@export_group("UPDOWN")
@export var nodeToMove: Node2D

func _physics_processUPDOWN(delta: float) -> void:
  nodeToMove.global_position.y = startPosition.y + sin(global.tick * 1.5) * 200
