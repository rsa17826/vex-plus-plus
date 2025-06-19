extends Control

var rect := Rect2()

func _draw() -> void:
  draw_rect(
    Rect2(global.boxSelectDrawStartPos, global.boxSelectDrawEndPos - global.boxSelectDrawStartPos),
  Color("1a14"))
  draw_rect(
    Rect2(global.boxSelectDrawStartPos, global.boxSelectDrawEndPos - global.boxSelectDrawStartPos),
  Color("1a1"), false, 3)

func updateRect():
   queue_redraw()