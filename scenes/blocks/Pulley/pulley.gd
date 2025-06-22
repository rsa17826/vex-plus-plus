@icon("images/1.png")
extends EditorBlock
class_name BlockPulley

@export var nodeToMove: Node2D = null
@export var sprite: Sprite2D = null
const SPEED = 1000
var direction = 0

var moving = false

func on_respawn():
  $movable.position = Vector2.ZERO
  if moving:
    moving = false
    nodeToMove.position = Vector2.ZERO
    if global.player.activePulley == self:
      global.player.state = global.player.States.falling
      global.player.activePulley = null
  setTexture(sprite, selectedOptions.direction)
  # get_node("../attach detector").on_respawn()

func _on_player_detector_body_entered(body: Node2D) -> void:
  log.pp(body, respawning, moving)
  if respawning or not %"has ceil".get_overlapping_bodies():
    return
  match selectedOptions.direction:
    "right":
      direction = 1
    "left":
      direction = -1
    "user":
      direction = -1 if global.player.get_node("anim").flip_h else 1
  moving = true
  global.player.activePulley = self
  global.player.state = global.player.States.onPulley

func on_physics_process(delta: float) -> void:
  if respawning:
    moving = false
    return
  if not moving:
    return
  nodeToMove.position.x += SPEED * delta * direction
  if global.player.state == global.player.States.onPulley and \
  %"wall to side with player on".get_overlapping_bodies():
    global.player.state = global.player.States.falling
  if %"wall to side with player off".get_overlapping_bodies():
    on_respawn()

func generateBlockOpts():
  blockOptions.direction = {"type": global.PromptTypes._enum, "default": "right", "values": [
    "left",
    "right",
    "user"
  ]}

func _on_has_ceil_body_exited(body: Node2D) -> void:
  if not %"has ceil".get_overlapping_bodies():
    on_respawn()
