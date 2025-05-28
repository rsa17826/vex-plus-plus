extends Node2D

@export var root: Node2D = null
const SPEED = 1300

func _on_attach_detector_body_entered(body: Node2D) -> void:
  pass # Replace with function body.

func _on_attach_detector_body_exited(body: Node2D) -> void:
  on_respawn()

func _on_deattach_detector_body_entered(body: Node2D) -> void:
  on_respawn()

func _on_deattach_detector_body_exited(body: Node2D) -> void:
  pass # Replace with function body.

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
  if root.respawning:
    return
  moving = true
  global.player.activePulley = self
  global.player.state = global.player.States.onPulley

func _physics_process(delta: float) -> void:
  if root.respawning:
    moving = false
    return
  if not moving:
    return
  position.x += SPEED * delta
