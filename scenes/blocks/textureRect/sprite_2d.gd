extends Node2D

@export var root: EditorBlock = null
@export var texture: Texture2D = null
var startScale

func _ready() -> void:
  startScale = scale
  $TextureRect.texture = texture

func _process(delta: float) -> void:
  global_scale = startScale
  $TextureRect.scale = Vector2(1, 1) / (1 if root.normalScale else 7)
  # $TextureRect.position = Vector2(0, 0) / 7
  $TextureRect.position = - root.sizeInPx / 2
  $TextureRect.size = root.sizeInPx * 7