extends ScrollContainer

const DEAD_ZONE := 12.0
const SPEED := 60.0 # scroll px per second per px of distance past the dead zone

var _autoscrolling := false
var _anchor := Vector2.ZERO

func _input(event: InputEvent) -> void:
  if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE): return
  if event.pressed:
    if not get_global_rect().has_point(event.position): return
    _autoscrolling = true
    _anchor = event.position
    Input.set_default_cursor_shape(Input.CURSOR_DRAG)
    get_viewport().set_input_as_handled()
  elif _autoscrolling:
    _autoscrolling = false
    Input.set_default_cursor_shape(Input.CURSOR_ARROW)
    get_viewport().set_input_as_handled()
  if event.is_action_pressed(&"ui_end"):
    scroll_vertical = int(get_v_scroll_bar().max_value)
  if event.is_action_pressed(&"ui_home"):
    scroll_vertical = 0

func _process(delta: float) -> void:
  if not _autoscrolling: return
  var offset := get_global_mouse_position() - _anchor
  offset.x = _apply_dead_zone(offset.x)
  offset.y = _apply_dead_zone(offset.y)
  scroll_horizontal += int(offset.x * SPEED * delta)
  scroll_vertical += int(offset.y * SPEED * delta)

func _apply_dead_zone(v: float) -> float:
  if absf(v) < DEAD_ZONE:
    return 0.0
  return v - signf(v) * DEAD_ZONE