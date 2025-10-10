extends ScrollContainer
func _input(event: InputEvent) -> void:
  if event.is_action_pressed(&"ui_end"):
    scroll_vertical = get_v_scroll_bar().max_value
  if event.is_action_pressed(&"ui_home"):
    scroll_vertical = 0