@icon("images/1.png")
extends EditorBlock
class_name BlockTimer

@export var charge: CircularProgressBar
@export var labelInp: Label
@export var labelOut: Label
@export var sprite: Sprite2D

var chargeState := States.discharged
var chargeTimer: float = 0
var lastOn = false

func generateBlockOpts():
  blockOptions.signalInputId = {"type": global.PromptTypes.int, "default": 0}
  blockOptions.chargeTime = {"type": global.PromptTypes.float, "default": 1}
  blockOptions.signalOutputId = {"type": global.PromptTypes.int, "default": 0}
  blockOptions.dischargeTime = {"type": global.PromptTypes.float, "default": 1}

func on_respawn():
  chargeState = States.discharged
  chargeTimer = 0
  global.onSignalChanged(onSignalChanged)
  labelInp.text = str(selectedOptions.signalInputId)
  labelOut.text = str(selectedOptions.signalOutputId)
  global.sendSignal(selectedOptions.signalOutputId, self , false)

func onSignalChanged(id, on, callers):
  breakpoint
  if self in callers: return
  if id == selectedOptions.signalInputId:
    if lastOn == on: return
    lastOn = on
    if on:
      if chargeState == States.discharged:
        chargeState = States.charging
      if chargeState == States.discharging:
        # chargeTimer = global.rerange(chargeTimer, 0, selectedOptions.dischargeTime, 0, selectedOptions.chargeTime)
        chargeState = States.charging
    else:
      if chargeState == States.charging:
        chargeState = States.discharged
        # chargeTimer = 0
      if chargeState == States.charged:
        chargeTimer = selectedOptions.dischargeTime
        chargeState = States.discharging

enum States {
  charging,
  charged,
  discharging,
  discharged
}

func on_physics_process(delta: float) -> void:
  log.pp(States.keys()[chargeState], chargeTimer, selectedOptions.chargeTime, selectedOptions.dischargeTime)
  match chargeState:
    States.charging, States.charged:
      charge.progress = global.rerange(chargeTimer, 0, selectedOptions.chargeTime, 0, 100)
    States.discharging, States.discharged:
      charge.progress = global.rerange(chargeTimer, 0, selectedOptions.dischargeTime, 0, 100)
  match chargeState:
    States.charging:
      chargeTimer += delta
      if chargeTimer >= selectedOptions.chargeTime:
        global.sendSignal(selectedOptions.signalOutputId, self , true)
        chargeState = States.charged
        global.sendSignal(selectedOptions.signalOutputId, self , true)
    States.discharging:
      if chargeTimer > 0:
        chargeTimer -= delta
        if chargeTimer <= 0:
          chargeState = States.discharged
          if lastOn:
            chargeState = States.charging
          global.sendSignal(selectedOptions.signalOutputId, self , false)