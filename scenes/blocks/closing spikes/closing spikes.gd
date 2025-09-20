@icon("images/1.png")
extends EditorBlock
class_name BlockClosingSpikes

@export var leftCollisionShape: CollisionShape2D
@export var rightCollisionShape: CollisionShape2D
@export var leftSprite: Sprite2D
@export var rightSprite: Sprite2D

func on_physics_process(delta: float) -> void:
  rotation_degrees = 0
  leftCollisionShape.global_position.x = startPosition.x + %collisionNode.global_position.x - global_position.x
  rightCollisionShape.global_position.x = startPosition.x + %collisionNode.global_position.x - global_position.x

  var newOffset: float = global.animate(80, [
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

func on_respawn() -> void:
  $Node2D.position = Vector2(0, 13)
  $Node2D/collisionNode.position = Vector2.ZERO
