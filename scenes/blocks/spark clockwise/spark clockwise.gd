extends "res://scenes/blocks/editor.gd"

@export_group("SPARK")
@export var spark: Node2D
@export var sprite: Sprite2D
var textureSize: Vector2
var base_speed = 20000.0

func on_respawn():
  textureSize = sprite.texture.get_size()
  spark.scale = Vector2(1, 1) / scale / 7

func on_physics_process(delta: float) -> void:
  var target: Vector2
  var totalSize = (textureSize.x + textureSize.y) * 2
  var effective_speed = base_speed / (scale.x + scale.y)
  var currentTick = fmod(global.tick * effective_speed * delta, totalSize)
  var side = 0
  var reqdist = 0

  if currentTick > reqdist + textureSize.x:
    reqdist += textureSize.x
    side += 1
    if currentTick > reqdist + textureSize.y:
      reqdist += textureSize.y
      side += 1
      if currentTick > reqdist + textureSize.x:
        reqdist += textureSize.x
        side += 1

  match side:
    0:
      target = Vector2(lerp(-1, 1, (currentTick - reqdist) / textureSize.x), -1)
    1:
      target = Vector2(1, lerp(-1, 1, (currentTick - reqdist) / textureSize.y))
    2:
      target = Vector2(lerp(1, -1, (currentTick - reqdist) / textureSize.x), 1)
    3:
      target = Vector2(-1, lerp(1, -1, (currentTick - reqdist) / textureSize.y))

  spark.position = textureSize * target / 2
