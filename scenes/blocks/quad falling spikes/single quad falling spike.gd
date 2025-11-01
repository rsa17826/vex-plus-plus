extends Area2D

@export var root: EditorBlock
var falling: bool = false

const speed = 3500.0

func _physics_process(delta: float) -> void:
  if falling:
    position += Vector2(0, -speed * delta).rotated(rotation)