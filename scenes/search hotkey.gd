extends LineEdit
func _unhandled_key_input(event: InputEvent) -> void:
  if global.mainMenu and global.mainMenu.loginMenuBg and global.mainMenu.loginMenuBg.visible: return
  if Input.is_action_just_pressed(&"focus_search", true):
    grab_focus()
    get_viewport().set_input_as_handled()
