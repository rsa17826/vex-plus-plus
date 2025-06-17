extends Control

var rect := Rect2()

func _draw() -> void:
  log.pp("drawing")
  draw_rect(
    Rect2(global.boxSelectStartPos, global.boxSelectEndPos - global.boxSelectStartPos),
  Color("a111"))

func updateRect():
  queue_redraw()

var point1: Vector2 = Vector2(0, 0)
var width: int = 10
var color: Color = Color.GREEN

var _point2: Vector2

func _process(_delta):
  var mouse_position = get_viewport().get_mouse_position()
  if mouse_position != _point2:
    _point2 = mouse_position
  queue_redraw()

# func _draw():
# 	draw_line(point1, _point2, color, width)