@icon("images/1.png")
extends EditorBlock
class_name BlockRightLeft

func on_physics_process(delta: float) -> void:
  thingThatMoves.global_position.x = startPosition.x + sin(global.tick * 1.5) * 200
