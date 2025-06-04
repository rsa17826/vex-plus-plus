extends "res://scenes/blocks/editor.gd"

@export_group("SOLAR")
func on_physics_process(delta: float) -> void:
  if global.player.lightsOut:
    __disable()
  else:
    __enable()
