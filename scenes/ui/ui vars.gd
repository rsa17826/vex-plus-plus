extends CanvasLayer
@export var levelSaved: Node2D
@export var editorBar: Node2D
@export var progressContainer: Control
@export var progressBar: ProgressBar
@export var modifiers: GridContainer
func _init() -> void:
  global.ui = self