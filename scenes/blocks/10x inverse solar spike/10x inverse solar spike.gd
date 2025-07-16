@icon("images/1.png")
extends EditorBlock
class_name Block10xInverseSolarSpike

func on_respawn():
  # $Node2D.position = Vector2(0, 11-72.5)
  thingThatMoves.position = Vector2.ZERO

func on_physics_process(delta: float) -> void:
  if global.player.lightsOut:
    __enable()
  else:
    __disable()
