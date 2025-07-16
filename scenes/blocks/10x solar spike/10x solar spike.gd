@icon("images/1.png")
extends EditorBlock
class_name Block10xSolarSpike

func on_respawn():
  # $Node2D.position = Vector2(0, 11-72.5)
  thingThatMoves.position = Vector2.ZERO

func on_physics_process(delta: float) -> void:
  if global.player.lightsOut:
    __disable()
  else:
    __enable()
