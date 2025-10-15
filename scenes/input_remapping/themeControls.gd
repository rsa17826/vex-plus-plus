extends "res://scenes/input_remapping/input_options_menu.gd"

func _ready() -> void:
  await global.wait()
  await global.wait()
  theme = get_window().theme