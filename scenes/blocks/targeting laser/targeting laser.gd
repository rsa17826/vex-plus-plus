@icon("images/1.png")
extends EditorBlock
class_name BlockTargetingLaser

@export var ray: RayCast2D

var hitPlayer: bool:
  get():
    return ray.is_colliding() and (ray.get_collider() is Player)

func on_body_entered(body: Node2D) -> void:
  if body is Player:
    if self not in global.player.targetingLasers:
      global.player.targetingLasers.append(self )

func on_body_exited(body: Node2D) -> void:
  if body is Player:
    if self in global.player.targetingLasers:
      global.player.targetingLasers.erase(self )
      queue_redraw()

func on_physics_process(delta: float) -> void:
  var targetAngle
  if self in global.player.targetingLasers:
    queue_redraw()
    targetAngle = global.player.global_position.angle_to_point(thingThatMoves.global_position)
    if ray.is_colliding():
      var block = ray.get_collider()
      if 'root' in block and block.root is BlockBomb:
        block.root.explode()
  else:
    targetAngle = 0
  thingThatMoves.rotation = lerp_angle(thingThatMoves.rotation, targetAngle, 0.5)

func _draw() -> void:
  if self in global.player.targetingLasers:
    # var end = ray.target_position.rotated(thingThatMoves.rotation)
    var end = Vector2.ZERO
    if ray.is_colliding():
      end = to_local(ray.get_collision_point())
    # else:
    #   log.err("no collision")
    draw_line(
      Vector2.ZERO + thingThatMoves.position,
      end,
      Color.RED,
      10
    )