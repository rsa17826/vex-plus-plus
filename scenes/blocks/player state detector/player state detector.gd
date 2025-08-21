@icon("images/1.png")
extends EditorBlock
class_name BlockPlayerStateDetector

@export var labelOut: Label
@export var bgSprite: Sprite2D
@export var playerSprite: Sprite2D

var lastInput = null

func generateBlockOpts():
  blockOptions.state = {"type": global.PromptTypes._enum, "default": 0, 'values': global.player.States}
  blockOptions.signalOutputId = {"type": global.PromptTypes.int, "default": 0}

func on_respawn():
  lastInput = null
  global.sendSignal(selectedOptions.signalOutputId, self , false)
  labelOut.text = str(selectedOptions.signalOutputId)
  labelOut.rotation = - rotation
  setTexture(playerSprite, global.player.States.keys()[selectedOptions.state])

func on_physics_process(delta: float) -> void:
  var temp = global.player.state == selectedOptions.state
  if temp != lastInput:
    lastInput = temp
  else: return
  if temp:
    global.sendSignal(selectedOptions.signalOutputId, self , true)
    setTexture(bgSprite, "1")
  else:
    global.sendSignal(selectedOptions.signalOutputId, self , false)
    setTexture(bgSprite, "2")
