extends Control

var rect := Rect2()

func _draw() -> void:
  var c = Color.hex(global.useropts.boxSelectColor)
  draw_rect(
    Rect2(global.boxSelectDrawStartPos, global.boxSelectDrawEndPos - global.boxSelectDrawStartPos),
  c)
  c.a = 1
  draw_rect(
    Rect2(global.boxSelectDrawStartPos, global.boxSelectDrawEndPos - global.boxSelectDrawStartPos),
  c, false, 3)

func updateRect():
  queue_redraw()