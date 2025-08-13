@icon("images/editorBar.png")
extends EditorBlock
class_name BlockNotGate

@export var labelInp: Label
@export var labelOut: Label

func generateBlockOpts():
  blockOptions.signalInputId = {"type": global.PromptTypes.int, "default": 0}
  blockOptions.signalOutputId = {"type": global.PromptTypes.int, "default": 0}

func on_respawn():
  global.onSignalChanged(onSignalChanged)
  labelInp.text = str(selectedOptions.signalInputId)
  labelOut.text = str(selectedOptions.signalOutputId)
  global.sendSignal(selectedOptions.signalOutputId, self , true)

func onSignalChanged(id, on, callers):
  if self in callers: return
  if id == selectedOptions.signalInputId:
    global.sendSignal(selectedOptions.signalOutputId, self , !on)

func onDelete():
  global.sendSignal(selectedOptions.signalOutputId, self , false)
