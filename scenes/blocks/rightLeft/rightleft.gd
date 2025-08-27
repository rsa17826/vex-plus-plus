@icon("images/1.png")
extends EditorBlock
class_name BlockRightLeft

func on_physics_process(delta: float) -> void:
  moveTo(Vector2(startPosition.x + sin(global.tick * 1.5) * 200, startPosition.y))
