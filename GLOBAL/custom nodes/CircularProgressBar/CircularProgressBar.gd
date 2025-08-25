@tool
extends Node2D
class_name CircularProgressBar

@export var bgColor: Color = Color(1, 0, 0):
  set(val):
    bgColor = val
    updateProgress()
@export var fgColor: Color = Color(0, 0, 0):
  set(val):
    fgColor = val
    updateProgress()
@export var progress: float = 0:
  set(val):
    progress = clamp(val, 0, 100)
    updateProgress()

func updateProgress():
  if not $s1: return
  if progress > 100 / 2.0:
    $s1.rotation_degrees = global.rerange(progress, 100, 100 / 2.0, 0, 180)
    $s3.visible = false
  else:
    $s3.visible = true
    $s1.rotation_degrees = 180
    $s3.rotation_degrees = clamp(global.rerange(progress, 100 / 2.0, 0, 180, 360), 180, 360)
  $s1.self_modulate = fgColor
  $s3.self_modulate = fgColor
  $bg.self_modulate = bgColor
  $mid.self_modulate = bgColor