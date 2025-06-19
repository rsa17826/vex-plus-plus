@icon("images/1.png")
extends EditorBlock
class_name BlockSolar

func on_physics_process(delta: float) -> void:
  log.pp(global.player.lightsOut)
  if global.player.lightsOut:
    __disable()
  else:
    __enable()
