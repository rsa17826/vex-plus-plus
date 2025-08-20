@tool
extends Node2D
# @noregex

@export var root: EditorBlock = null
@export var texture: Texture2D = null
@export var editorSize: Vector2 = Vector2(700, 700)

var startScale

func property_changed(what):
  # log.pp(what, "changed to", self [what])
  $TextureRect.texture = texture
  $TextureRect.scale = Vector2(1, 1)
  $TextureRect.position = Vector2.ZERO
  $TextureRect.position = - editorSize / 2
  $TextureRect.size = editorSize

func _ready() -> void:
  if Engine.is_editor_hint():
    Engine.get_singleton(&"EditorInterface").get_inspector().property_edited.connect(property_changed)
    property_changed('a')
  else:
    $TextureRect.texture = texture
    startScale = scale

func _process(delta: float) -> void:
  if Engine.is_editor_hint(): return
  global_scale = startScale
  $TextureRect.scale = Vector2(1, 1) / (1 if root.normalScale else 7)
  $TextureRect.position = - (abs(root.sizeInPx) / abs(global_scale)) / 2
  $TextureRect.size = abs(root.sizeInPx) * 7 / abs(global_scale)
