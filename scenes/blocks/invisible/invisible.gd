@icon("images/1.png")
extends EditorBlock
class_name BlockInvisible

@export var sprite: Sprite2D

func on_physics_process(delta: float) -> void:
  var top = thingThatMoves.global_position.y - (sizeInPx.y / 2)
  var left = thingThatMoves.global_position.x - (sizeInPx.x / 2)
  var right = thingThatMoves.global_position.x + (sizeInPx.x / 2)
  var bottom = thingThatMoves.global_position.y + (sizeInPx.y / 2)
  var pos = global.player.global_position

  # Clamp position to rectangle bounds
  var closest_x = clamp(pos.x, left, right)
  var closest_y = clamp(pos.y, top, bottom)

  # Calculate distance between pos and closest point
  var closest_point = Vector2(closest_x, closest_y)
  var distance = pos.distance_to(closest_point)
  var newval = clamp(global.rerange(distance, 70, 700, 0.0, 1.0), 0.0, 1.0)
  sprite.self_modulate.a = lerp(sprite.self_modulate.a, newval, 0.2)