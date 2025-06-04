extends "res://scenes/blocks/editor.gd"

@export_group("CLOSING_SPIKES")
@export var leftCollisionShape: CollisionShape2D
@export var rightCollisionShape: CollisionShape2D
@export var leftSprite: Sprite2D
@export var rightSprite: Sprite2D

func on_physics_process(delta: float) -> void:
  rotation_degrees = 0
  leftCollisionShape.global_position = startPosition + %collisionNode.global_position - global_position
  rightCollisionShape.global_position = startPosition + %collisionNode.global_position - global_position

  var newOffset := global.animate(80, [
    {
      "until": 120,
      "from": - 189.0,
      "to": - 400.0
    },
    {
      "until": 130,
      "from": - 400.0,
      "to": - 189.0
    },
    {
      "until": 160,
      "from": - 189.0,
      "to": - 189.0
    }
  ]) * scale.x

  leftCollisionShape.global_position.x += newOffset
  leftSprite.global_position.x = leftCollisionShape.global_position.x
  rightCollisionShape.global_position.x -= newOffset
  rightSprite.global_position.x = rightCollisionShape.global_position.x
  rotation_degrees = startRotation_degrees