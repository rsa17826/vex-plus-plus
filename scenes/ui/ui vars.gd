extends CanvasLayer
@export var levelSaved: Node2D
@export var editorBar: Node2D
@export var progressContainer: Control
@export var progressBar: ProgressBar
@export var modifiers: Control
@export var signalList: Control
@export var blockMenu: Control
@export var hoveredBlockList: Control
@export var overlayRemovalHidersubViewportContainer: SubViewportContainer
@export var othersubViewportContainer: SubViewportContainer

func _init() -> void:
  global.ui = self