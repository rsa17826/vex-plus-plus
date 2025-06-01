extends CanvasLayer
@export var levelSaved: Node2D
@export var editorBar: Node2D
func _ready() -> void:
  global.ui = self