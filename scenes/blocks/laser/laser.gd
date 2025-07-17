@icon("images/1.png")
extends EditorBlock
class_name BlockLaser

@export var charge1: Sprite2D
@export var charge2: Sprite2D
@export var charge3: Sprite2D

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

  if targetingPlayer and cooldown <= 0:
    var projectile: EditorBlock = load("res://scenes/blocks/laser/projectile.tscn").instantiate()
    projectile.global_position = thingThatMoves.global_position
    projectile.rotation = thingThatMoves.rotation
    cooldown = selectedOptions.maxCooldown
    projectile.scale = startScale * 7
    global.level.add_child(projectile)

func on_process(delta):
  if cooldown > 0:
    cooldown -= delta
    updateCharge()
    
func updateCharge():
  var maxCooldown: float = selectedOptions.maxCooldown
  if cooldown > maxCooldown / 2.0:
    charge1.rotation_degrees = global.rerange(cooldown, maxCooldown, maxCooldown / 2.0, 0, 180)
    # charge1.visible = true
    # charge2.visible = true
    charge3.visible = false
  else:
    charge3.visible = true
    charge1.rotation_degrees = 180
    charge3.rotation_degrees = clamp(global.rerange(cooldown, maxCooldown / 2.0, 0, 180, 360), 180, 360)

func on_respawn():
  cooldown = 0
  updateCharge()

func generateBlockOpts():
  blockOptions.maxCooldown = {"default": 1, "type": global.PromptTypes.float}