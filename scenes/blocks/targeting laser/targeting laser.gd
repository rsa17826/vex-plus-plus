@icon("images/1.png")
extends EditorBlock
class_name BlockTargetingLaser

@export var ray: RayCast2D

var targets: Array[Player] = []

func hitsPlayer(p: Player) -> bool:
  return ray.is_colliding() and ray.get_collider() == p

func nearestTarget() -> Player:
  var best: Player = null
  for p: Player in targets:
    if not best or p.global_position.distance_to(thingThatMoves.global_position) < best.global_position.distance_to(thingThatMoves.global_position):
      best = p
  return best

func on_body_entered(body: Node2D) -> void:
  if body is Player:
    if body not in targets:
      targets.append(body)
    if self not in body.targetingLasers:
      body.targetingLasers.append(self)

func on_body_exited(body: Node2D) -> void:
  if body is Player:
    targets.erase(body)
    if self in body.targetingLasers:
      body.targetingLasers.erase(self)
      queue_redraw()

func on_physics_process(delta: float) -> void:
  var targetAngle
  var target := nearestTarget()
  if target:
    queue_redraw()
    targetAngle = target.global_position.angle_to_point(thingThatMoves.global_position)
    if ray.is_colliding():
      var block = ray.get_collider()
      if 'root' in block and block.root is BlockBomb:
        block.root.explode()
  else:
    targetAngle = 0
  thingThatMoves.rotation = lerp_angle(thingThatMoves.rotation, targetAngle, 0.5)

func _draw() -> void:
  if targets:
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
