@icon("images/1.png")
extends EditorBlock
class_name BlockSparkCounterClockwise

@export var spark: Node2D
@export var sprite: Sprite2D
var textureSize: Vector2
var base_speed = 20000.0

func on_respawn():
  textureSize = sprite.texture.get_size()
  spark.scale = Vector2(1, 1) / scale / 7

func on_physics_process(delta: float) -> void:
  var px = textureSize * scale * 2
  var target: Vector2
  var currentTick = fmod(global.tick * base_speed * delta, (px.x + px.y) * 2)
  var side = 0
  var reqdist = 0

  if currentTick > reqdist + px.x:
    reqdist += px.x
    side += 1
    if currentTick > reqdist + px.y:
      reqdist += px.y
      side += 1
      if currentTick > reqdist + px.x:
        reqdist += px.x
        side += 1

  match side:
    0:
      target = Vector2(lerp(1, -1, (currentTick - reqdist) / px.x), -1)
    1:
      target = Vector2(-1, lerp(-1, 1, (currentTick - reqdist) / px.y))
    2:
      target = Vector2(lerp(-1, 1, (currentTick - reqdist) / px.x), 1)
    3:
      target = Vector2(1, lerp(1, -1, (currentTick - reqdist) / px.y))

  spark.position = textureSize * target / 2
