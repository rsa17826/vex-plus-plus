@tool
extends InputOptionsMenu

func _input(event: InputEvent) -> void:
  if event is InputEventKey:
    if Input.is_action_just_pressed("show_keybinds", true):
      visible = !visible
      global.ctrlMenuVisible = visible

func close():
  visible = false
  global.ctrlMenuVisible = visible