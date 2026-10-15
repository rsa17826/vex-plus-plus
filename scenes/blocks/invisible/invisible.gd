@icon("images/1.png")
extends EditorBlock
class_name BlockInvisible

@export var sprite: Sprite2D

func on_physics_process(delta: float) -> void:
  var top = thingThatMoves.global_position.y - (sizeInPx.y / 2)
  var left = thingThatMoves.global_position.x - (sizeInPx.x / 2)
  var right = thingThatMoves.global_position.x + (sizeInPx.x / 2)
  var bottom = thingThatMoves.global_position.y + (sizeInPx.y / 2)
  var distance := INF
  for p: Player in global.players:
    var pos = p.global_position
    # Clamp position to rectangle bounds
    var closest_point = Vector2(clamp(pos.x, left, right), clamp(pos.y, top, bottom))
    distance = min(distance, pos.distance_to(closest_point))
  var newval = clamp(global.rerange(distance, 70, 700, 0.0, 1.0), 0.0, 1.0)
  sprite.modulate.a = lerp(sprite.modulate.a, newval, 0.2)
  for block: EditorBlock in attach_children:
    for childSprite: Node2D in block.hidableSprites:
      childSprite.modulate.a = sprite.modulate.a
