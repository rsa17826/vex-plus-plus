@icon("images/1.png")
extends EditorBlock
class_name BlockPlayerStateDetector

@export var labelOut: Label
@export var bgSprite: Sprite2D
@export var playerSprite: Sprite2D

var lastInput = null

func generateBlockOpts():
  blockOptions.state = {"type": global.PromptTypes._enum, "default": 0, 'values': States}
  blockOptions.signalOutputId = {"type": global.PromptTypes.int, "default": 0}

enum States {
  idle,
  moving,
  jumping,
  wallHang,
  falling,
  wallSliding,
  sliding,
  ducking,
  bouncing,
  inCannon,
  pullingLever,
  swingingOnPole,
  onPulley,
  pushing,
  facingLeft,
  facingRight,
}

func on_respawn():
  lastInput = null
  global.sendSignal(selectedOptions.signalOutputId, self , false)
  labelOut.text = str(selectedOptions.signalOutputId)
  labelOut.rotation = - rotation
  setTexture(playerSprite, States.keys()[selectedOptions.state])

func on_physics_process(delta: float) -> void:
  var temp = (func(p):
    match selectedOptions.state:
      States.idle:
        return p.state == p.States.idle
      States.moving:
        return p.state == p.States.moving
      States.jumping:
        return p.state == p.States.jumping
      States.wallHang:
        return p.state == p.States.wallHang
      States.falling:
        return p.state == p.States.falling
      States.wallSliding:
        return p.state == p.States.wallSliding
      States.sliding:
        return p.state == p.States.sliding and abs(p.vel.user.x) >= 10
      States.ducking:
        return p.state == p.States.sliding and abs(p.vel.user.x) < 10
      States.bouncing:
        return p.state == p.States.bouncing
      States.inCannon:
        return p.state == p.States.inCannon
      States.pullingLever:
        return p.state == p.States.pullingLever
      States.swingingOnPole:
        return p.state == p.States.swingingOnPole
      States.onPulley:
        return p.state == p.States.onPulley
      States.pushing:
        return p.state == p.States.pushing
      States.facingLeft:
        return p.anim.flip_h
      States.facingRight:
        return !p.anim.flip_h
    ).call(global.player)
  if temp != lastInput:
    lastInput = temp
  else: return
  if temp:
    global.sendSignal(selectedOptions.signalOutputId, self , true)
    setTexture(bgSprite, "1")
  else:
    global.sendSignal(selectedOptions.signalOutputId, self , false)
    setTexture(bgSprite, "2")
