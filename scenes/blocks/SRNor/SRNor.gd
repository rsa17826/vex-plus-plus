@icon("images/editorBar.png")
extends EditorBlock
class_name BlockSRNor

@export var labelEnable: Label
@export var labelDisable: Label
@export var labelOut: Label

var isOn = false

func generateBlockOpts():
  blockOptions.enableSignalInputId = {"type": global.PromptTypes.int, "default": 0}
  blockOptions.disableSignalInputId = {"type": global.PromptTypes.int, "default": 0}
  blockOptions.signalOutputId = {"type": global.PromptTypes.int, "default": 0}
  blockOptions.persistAfterDeath = {"type": global.PromptTypes.bool, "default": false}
  blockOptions.startOn = {"type": global.PromptTypes.bool, "default": false}

func on_ready() -> void:
  isOn = selectedOptions.startOn

func on_respawn():
  if !root.loadDefaultData and !selectedOptions.persistAfterDeath:
    isOn = selectedOptions.startOn
  global.onSignalChanged(onSignalChanged)
  labelEnable.text = str(selectedOptions.enableSignalInputId)
  labelDisable.text = str(selectedOptions.disableSignalInputId)
  labelOut.text = str(selectedOptions.signalOutputId)
  global.sendSignal(selectedOptions.signalOutputId, self , isOn)

func onSignalChanged(id, on, callers):
  if self in callers: return
  if id == selectedOptions.enableSignalInputId and on:
    isOn = true
  elif id == selectedOptions.disableSignalInputId and on:
    isOn = false
  else: return
  global.sendSignal(selectedOptions.signalOutputId, self , isOn)

func onSave() -> Array:
  return ['isOn'] if selectedOptions.persistAfterDeath else []

func onDelete():
  global.sendSignal(selectedOptions.signalOutputId, self , false)
