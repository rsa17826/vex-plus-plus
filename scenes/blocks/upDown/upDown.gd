@icon("images/1.png")
extends EditorBlock
class_name BlockUpdown

func on_physics_process(delta: float) -> void:
  moveTo(Vector2(startPosition.x, startPosition.y - sin(global.tick * 1.5) * 200))
