@icon("images/1.png")
extends EditorBlock
class_name BlockGoal

@export_group("GOAL")
@export var sprite: Node2D
@export var CollisionShape: Node2D

func on_respawn():
  $collisionNode.position = Vector2.ZERO

func on_ready() -> void:
  if selectedOptions.requiredLevelCount > len(global.beatLevels):
    sprite.modulate = Color("#555")
    CollisionShape.disabled = true

func on_body_entered(body: Node) -> void:
  if body == global.player:
    if selectedOptions.requiredLevelCount > len(global.beatLevels): return
    global.win()

func generateBlockOpts():
  blockOptions.requiredLevelCount = {"type": global.PromptTypes.int, "default": 0}