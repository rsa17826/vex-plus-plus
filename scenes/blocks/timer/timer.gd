@icon("images/1.png")
extends EditorBlock
class_name BlockTimer

@export var labelInp: Label
@export var labelOut: Label
@export var sprite: Sprite2D

var chargeState := States.discharged
var chargeTimer: float = 0
var lastOn = false

func generateBlockOpts():
  blockOptions.signalInputId = {"type": global.PromptTypes.int, "default": 0}
  blockOptions.signalInputTime = {"type": global.PromptTypes.float, "default": 0}
  blockOptions.signalOutputId = {"type": global.PromptTypes.int, "default": 0}

func on_respawn():
  chargeState = States.discharged
  chargeTimer = 0
  global.onSignalChanged(onSignalChanged)
  labelInp.text = str(selectedOptions.signalInputId)
  labelOut.text = str(selectedOptions.signalOutputId)
  global.sendSignal(selectedOptions.signalOutputId, self , false)

func onSignalChanged(id, on, callers):
  if self in callers: return
  if id == selectedOptions.signalInputId:
    if lastOn == on: return
    lastOn = on
    if on:
      if chargeState == States.discharged:
        chargeState = States.charging
    else:
      if chargeState == States.charging:
        chargeState = States.discharged
        chargeTimer = 0
      if chargeState == States.charged:
        chargeState = States.discharging

enum States {
  charging,
  charged,
  discharging,
  discharged
}

func on_physics_process(delta: float) -> void:
  log.pp(States.keys()[chargeState])
  match chargeState:
    States.charging:
      chargeTimer += delta
      log.pp(chargeTimer)
      if chargeTimer >= selectedOptions.signalInputTime:
        global.sendSignal(selectedOptions.signalOutputId, self , true)
        chargeState = States.charged
        global.sendSignal(selectedOptions.signalOutputId, self , true)
    States.discharging:
      if chargeTimer > 0:
        chargeTimer -= delta
        if chargeTimer <= 0:
          chargeState = States.discharged
          global.sendSignal(selectedOptions.signalOutputId, self , false)