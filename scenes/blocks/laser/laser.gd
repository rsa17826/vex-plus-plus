@icon("images/1.png")
extends EditorBlock
class_name BlockLaser

const MAX_COOLDOWN = 1.0
var targetingPlayer := false
var cooldown := 0.0

func on_body_entered(body: Node2D) -> void:
  if body is Player:
    targetingPlayer = true

func on_body_exited(body: Node2D) -> void:
  if body is Player:
    targetingPlayer = false

func on_physics_process(delta: float) -> void:
  var targetAngle
  if targetingPlayer:
    targetAngle = global.player.global_position.angle_to_point(thingThatMoves.global_position)
  else:
    targetAngle = 0
  thingThatMoves.rotation = lerp_angle(thingThatMoves.rotation, targetAngle, 0.5)
  if cooldown > 0:
    cooldown -= delta
  if targetingPlayer and cooldown <= 0:
    var projectile = load("res://scenes/blocks/laser/projectile.tscn").instantiate()
    projectile.global_position = thingThatMoves.global_position
    projectile.rotation = thingThatMoves.rotation
    cooldown = MAX_COOLDOWN
    global.level.add_child(projectile)

func on_respawn():
  cooldown = 0

