@icon("images/1.png")
extends EditorBlock
class_name BlockDownUp

func on_physics_process(delta: float) -> void:
  thingThatMoves.global_position.y = startPosition.y - sin(global.tick * 1.5) * 200

