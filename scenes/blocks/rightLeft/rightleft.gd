@icon("images/1.png")
extends EditorBlock
class_name BlockRightLeft

func on_physics_process(delta: float) -> void:
  moveTo(Vector2(startPosition.x + sin(global.tick * selectedOptions.speed) * selectedOptions.magnitude, startPosition.y))

func generateBlockOpts():
  blockOptions.magnitude = {"type": global.PromptTypes.int, "default": 200}
  blockOptions.speed = {"type": global.PromptTypes.float, "default": 1.5}
