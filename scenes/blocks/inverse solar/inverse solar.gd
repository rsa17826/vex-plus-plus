@icon("images/1.png")
extends EditorBlock
class_name BlockInverseSolar

func on_physics_process(delta: float) -> void:
  if global.player.lightsOut:
    __enable()
  else:
    __disable()
  for block: EditorBlock in attach_children:
    if global.player.lightsOut:
      block.__enable()
    else:
      block.__disable()
