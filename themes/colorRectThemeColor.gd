extends ColorRect

@export var alpha: bool = true

func _ready() -> void:
  if "theme" in global.useropts:
    color = Color(
      ['#2d2d2d', "#374165da", "#2d2d2d99"] \
      [global.useropts.theme]
    )
  await global.wait()
  color = Color(
    ['#2d2d2d', "#374165da", "#2d2d2d99"] \
    [global.useropts.theme]
  )
  if not alpha:
    color.a = 1