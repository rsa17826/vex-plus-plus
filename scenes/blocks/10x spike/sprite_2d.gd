extends Node2D

@export var root: EditorBlock = null

func _process(delta: float) -> void:
  global_scale = Vector2(0.978, 1)
  $TextureRect.size = root.sizeInPx