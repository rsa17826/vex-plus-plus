@icon("images/1.png")
extends EditorBlock
class_name BlockAndGate

var aon = false
var bon = true

func generateBlockOpts():
  blockOptions.signalAInputId = {"type": global.PromptTypes.int, "default": 0}
  blockOptions.signalBInputId = {"type": global.PromptTypes.int, "default": 0}
  blockOptions.signalOutputId = {"type": global.PromptTypes.int, "default": 0}

func on_respawn():
  global.onSignalChanged(onSignalChanged)
  global.sendSignal(selectedOptions.signalOutputId, self , false)

func onSignalChanged(id, on, callers):
  if self in callers: return
  if id not in [selectedOptions.signalAInputId, selectedOptions.signalBInputId]: return
  if id == selectedOptions.signalAInputId:
    aon = on
  elif id == selectedOptions.signalBInputId:
    bon = on
  global.sendSignal(selectedOptions.signalOutputId, self , aon and bon)
