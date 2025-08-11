extends ColorRect

func _ready() -> void:
  await global.wait()
  color = Color(
    ['#2d2d2d', "#2c324999", "#2d2d2d99"]\
    [global.useropts.theme]
  )