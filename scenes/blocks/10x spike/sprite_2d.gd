extends Node2D

@export var root: EditorBlock = null
@export var texture: Texture2D = null

func _process(delta: float) -> void:
  global_scale = Vector2(0.983, 1)
  $TextureRect.scale = Vector2(1, 1) / 7
  $TextureRect.position = Vector2(0, 0) / 7
  $TextureRect.position -= root.sizeInPx / 2
  $TextureRect.size = root.sizeInPx * 7