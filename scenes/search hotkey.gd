extends LineEdit
func _unhandled_key_input(event: InputEvent) -> void:
  if get_viewport().gui_get_focus_owner() != null: return
  if Input.is_action_just_pressed(&"focus_search", true):
    grab_focus()
    get_viewport().set_input_as_handled()
