@icon("images/1.png")
extends EditorBlock
class_name BlockInvisible

func on_physics_process(delta: float) -> void:
  var top = thingThatMoves.global_position.y + (sizeInPx.y / 2)
  var left = thingThatMoves.global_position.x + (sizeInPx.x / 2)
  var right = thingThatMoves.global_position.x - (sizeInPx.x / 2)
  var bottom = thingThatMoves.global_position.y - (sizeInPx.y / 2)
  var pos = global.player.global_position

  # Clamp position to rectangle bounds
  var closest_x = clamp(pos.x, left, right)
  var closest_y = clamp(pos.y, top, bottom)

  # If pos is outside the rectangle, find closest point
  if pos.x < left:
    closest_x = left
  elif pos.x > right:
    closest_x = right

  if pos.y < top:
    closest_y = top
  elif pos.y > bottom:
    closest_y = bottom

  # Calculate distance between pos and closest point
  var closest_point = Vector2(closest_x, closest_y)
  var distance = pos.distance_to(closest_point)
  log.pp(distance)
