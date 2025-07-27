@icon("images/1.png")
extends EditorBlock
class_name BlockInputDetector

var actions = ["jump", "down", "left", "right"]

func generateBlockOpts():
  blockOptions.action = {"type": global.PromptTypes._enum, "default": 0, 'values': actions}
  blockOptions.signalOutputId = {"type": global.PromptTypes.int, "default": 0}

func on_respawn():
  global.sendSignal(selectedOptions.signalOutputId, self , false)

func _input(event):
  if Input.is_action_pressed(actions[selectedOptions.action]):
    global.sendSignal(selectedOptions.signalOutputId, self , true)
  else:
    global.sendSignal(selectedOptions.signalOutputId, self , false)