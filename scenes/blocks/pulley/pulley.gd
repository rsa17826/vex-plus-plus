@icon("images/editorBar.png")
extends EditorBlock
class_name BlockPulley

@export var sprite: Sprite2D

const SPEED = 1000
var direction = 0

var moving = false

func on_respawn():
  if loadDefaultData:
    thingThatMoves.position = Vector2(0, 1)
    if moving:
      moving = false
      thingThatMoves.position = Vector2.ZERO
      if global.player.activePulley == self:
        global.player.state = global.player.States.falling
        global.player.remainingJumpCount -= 1
        global.player.activePulley = null
    setTexture(sprite, ["left", 'right', "user"][selectedOptions.direction])
    await global.wait()
    thingThatMoves.position = Vector2.ZERO

func _on_player_detector_body_entered(body: Node2D) -> void:
  if respawning: return
  if not %"has ceil".get_overlapping_bodies():
    # fix for if the ceil is placed after the pulley is
    thingThatMoves.position = Vector2(0, 1)
    await global.wait()
    thingThatMoves.position = Vector2.ZERO
    await global.wait()
    if not %"has ceil".get_overlapping_bodies(): return
  match selectedOptions.direction:
    0:
      direction = -1
    1:
      direction = 1
    2:
      direction = -1 if global.player.get_node("anim").flip_h else 1
  moving = true
  global.player.activePulley = self
  global.player.state = global.player.States.onPulley

func on_physics_process(delta: float) -> void:
  if respawning: return
  if not moving: return
  thingThatMoves.position.x += SPEED * delta * direction
  if global.player.state == global.player.States.onPulley \
  and global.player.activePulley == self \
  and %"wall to side with player on".get_overlapping_bodies():
    global.player.state = global.player.States.falling
    global.player.activePulley = null
    global.player.remainingJumpCount -= 1
  if %"wall to side with player off".get_overlapping_bodies():
    respawn()

func generateBlockOpts():
  blockOptions.direction = {"type": global.PromptTypes._enum, "default": 1, "values": [
    "left",
    "right",
    "user"
  ]}

func _on_has_ceil_body_exited(body: Node2D) -> void:
  if not %"has ceil".get_overlapping_bodies():
    respawn()

func onSave() -> Array[String]:
  return ["direction", "moving", "thingThatMoves.global_position"]
