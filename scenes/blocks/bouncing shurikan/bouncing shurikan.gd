@icon("images/1.svg")
extends EditorBlock
class_name BlockBouncingShurikan

@export var sprite: Sprite2D

func on_process(delta: float) -> void:
  spin(150, sprite)
