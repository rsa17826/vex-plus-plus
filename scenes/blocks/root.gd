@icon("root.png")
extends Node2D

@export var root: EditorBlock
var falling: bool = false

const speed = 3500.0

func _ready():
  if not root:
    log.err(root, "not set", get_parent().id, get_parent().get_parent().id)
    breakpoint

func _physics_process(delta: float) -> void:
  if falling:
    position += Vector2(0, -speed * delta).rotated(rotation)