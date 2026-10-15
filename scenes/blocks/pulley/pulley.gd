@icon("images/editorBar.png")
extends EditorBlock
class_name BlockPulley

@export var sprite: Sprite2D
@export var hasCeil: Area2D
@export var wallToSideWithPlayerOn: Area2D
@export var wallToSideWithPlayerOff: Area2D

const SPEED = 1000
var direction = 0

var moving = false
## the player currently riding this pulley
var rider: Player

func releaseRider() -> void:
  if not rider: return
  if rider.activePulley == self:
    rider.state = Player.States.falling
    rider.remainingJumpCount -= 1
    rider.activePulley = null
  rider = null

func on_respawn():
  if loadDefaultData:
    thingThatMoves.position = Vector2(0, 1)
    if moving:
      moving = false
      thingThatMoves.position = Vector2.ZERO
      releaseRider()
    setTexture(sprite, ["left", 'right', "user"][selectedOptions.direction])
    await global.wait()
    thingThatMoves.position = Vector2.ZERO

func _on_player_detector_body_entered(body: Node2D) -> void:
  if respawning: return
  if not body is Player: return
  if moving: return
  if not hasCeil.get_overlapping_bodies():
    # fix for if the ceil is placed after the pulley is
    thingThatMoves.position = Vector2(0, 1)
    await global.wait()
    thingThatMoves.position = Vector2.ZERO
    await global.wait()
    if not hasCeil.get_overlapping_bodies(): return
  match selectedOptions.direction:
    0:
      direction = -1
    1:
      direction = 1
    2:
      direction = -1 if body.anim.flip_h else 1
  moving = true
  rider = body
  body.activePulley = self
  body.state = Player.States.onPulley

func on_physics_process(delta: float) -> void:
  if respawning: return
  if not moving: return
  thingThatMoves.position.x += SPEED * delta * direction
  if rider and rider.state == Player.States.onPulley \
  and rider.activePulley == self \
  and wallToSideWithPlayerOn.get_overlapping_bodies():
    releaseRider()
  if wallToSideWithPlayerOff.get_overlapping_bodies():
    respawn()

func generateBlockOpts():
  blockOptions.direction = {"type": global.PromptTypes._enum, "default": 1, "values": [
    "left",
    "right",
    "user"
  ]}

func _on_has_ceil_body_exited(body: Node2D) -> void:
  if not hasCeil.get_overlapping_bodies():
    respawn()

func onSave() -> Array[String]:
  return ["direction", "moving", "thingThatMoves.global_position"]
