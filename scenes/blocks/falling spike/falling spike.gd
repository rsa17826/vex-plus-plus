extends "res://scenes/blocks/editor.gd"

@export_group("FALLING SPIKE")
@export var nodeToFall: Node2D

func on_respawn():
  falling = false
  $Node2D.position = Vector2.ZERO
  # $Node2D/collisionNode.position = Vector2(0, 13)

var falling: bool = false

func on_physics_process(delta: float) -> void:
  var speed = 300.0
  if falling:
    position += Vector2(0, -speed * delta).rotated(rotation)
