extends Area2D
# @name same line return
# @regex :\s*return\s*$
# @replace : return
# @flags gm
# @endregex

@export var id: int = 0
var normalScale = Vector2.ZERO
var selected = 0
var blockName := ''

func _on_mouse_entered() -> void:
  scale = normalScale * 1.1
  z_index = 2
  selected = 1

func _input(event: InputEvent) -> void:
  if selected >= 1 and Input.is_action_just_pressed("editor_select"):
    global.selectedBrush = self
    selected = 2
    global.localProcess(0)
  if !Input.is_action_pressed("editor_select"):
    global.justPaintedBlock = null
    global.selectedBrush = null

func _on_mouse_exited() -> void:
  scale = normalScale
  z_index = 1
  selected = 0
