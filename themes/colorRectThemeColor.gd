extends ColorRect

func _ready() -> void:
  await global.wait()
  color = Color(
    ['#2d2d2d', "#2c3249", "#2d2d2d"]\
    [global.useropts.theme]
  )