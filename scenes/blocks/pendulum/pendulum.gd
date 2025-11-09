@icon("images/editorBar.png")
extends EditorBlock
class_name BlockPendulum

@export var bottomSprite: Sprite2D
@export var rotNode: Node2D
@export var cbody: Node2D
var lastPos = Vector2.ZERO

func on_respawn():
  await global.wait()
  await global.wait()
  lastPos = cbody.global_position

func on_physics_process(delta: float) -> void:
  spin(selectedOptions.rotationSpeed, rotNode)
  bottomSprite.global_rotation_degrees = startRotation_degrees
  cbody.position = Vector2(0, 939).rotated(rotNode.global_rotation - deg_to_rad(startRotation_degrees))

func postMovementStep():
  lastMovementStep = (cbody.global_position - lastPos)
  lastPos = cbody.global_position

func generateBlockOpts() -> void:
  blockOptions.rotationSpeed = {"type": global.PromptTypes.float, "default": 100}