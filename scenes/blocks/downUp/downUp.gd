@icon("images/1.png")
extends EditorBlock
class_name BlockDownUp

func on_physics_process(delta: float) -> void:
  moveTo(Vector2(startPosition.x, startPosition.y + sin(global.tick * selectedOptions.speed) * selectedOptions.magnitude))

func generateBlockOpts():
  blockOptions.magnitude = {"type": global.PromptTypes.int, "default": 200}
  blockOptions.speed = {"type": global.PromptTypes.float, "default": 1.5}
