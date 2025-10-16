@tool
extends InputOptionsMenu

func _init() -> void:
  global.ctrlMenu = self

func _input(event: InputEvent) -> void:
  if event is InputEventKey:
    if Input.is_action_just_pressed("show_keybinds", true):
      visible = !visible

func close():
  visible = false