extends Node2D

@export var root: Node2D = null
const SPEED = 1000
var direction = 0

func _on_attach_detector_body_exited(body: Node2D) -> void:
  if not get_node("has ceil").get_overlapping_bodies():
    on_respawn()

var moving = false

func on_respawn():
  if moving:
    moving = false
    position = Vector2.ZERO
    if global.player.activePulley == self:
      global.player.state = global.player.States.falling
      global.player.activePulley = null
  get_node("../attach detector").on_respawn()

func _on_player_detector_body_entered(body: Node2D) -> void:
  log.pp(body, root.respawning, moving)
  if root.respawning or not len(get_node("has ceil").get_overlapping_bodies()):
    return
  match root.selectedOptions.direction:
    "right":
      direction = 1
    "left":
      direction = -1
    "user":
      direction = -1 if global.player.get_node("anim").flip_h else 1
  moving = true
  global.player.activePulley = self
  global.player.state = global.player.States.onPulley

func _physics_process(delta: float) -> void:
  if root.respawning:
    moving = false
    return
  if not moving:
    return
  position.x += SPEED * delta * direction
  if global.player.state == global.player.States.onPulley and \
  len(get_node(
    "wall to side with player on"
  ).get_overlapping_bodies()):
    global.player.state = global.player.States.falling
  if len(get_node(
    "wall to side with player off"
  ).get_overlapping_bodies()):
    on_respawn()
