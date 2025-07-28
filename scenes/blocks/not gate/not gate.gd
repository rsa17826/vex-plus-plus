@icon("images/1.png")
extends EditorBlock
class_name BlockNotGate

func generateBlockOpts():
  blockOptions.signalInputId = {"type": global.PromptTypes.int, "default": 0}
  blockOptions.signalOutputId = {"type": global.PromptTypes.int, "default": 0}

func on_respawn():
  global.onSignalChanged(onSignalChanged)
  global.sendSignal(selectedOptions.signalOutputId, self , false)

func onSignalChanged(id, on, callers):
  if self in callers: return
  if id == selectedOptions.signalInputId:
    global.sendSignal(selectedOptions.signalOutputId, self , !on)
