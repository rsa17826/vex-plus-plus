@icon("images/1.png")
extends EditorBlock
class_name BlockSolar

func on_physics_process(delta: float) -> void:
  if global.lightsOut:
    __disable()
  else:
    __enable()
  for block: EditorBlock in attach_children:
    if global.lightsOut:
      block.__disable()
    else:
      block.__enable()
