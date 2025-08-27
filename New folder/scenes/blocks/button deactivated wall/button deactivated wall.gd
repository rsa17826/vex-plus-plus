@icon("images/1.png")
extends EditorBlock
class_name BlockButtonDeactivatedWall

func on_respawn() -> void:
  global.onSignalChanged(on_signal_changed)

func on_signal_changed(id, on, callers):
  if self in callers: return
  if id == selectedOptions.signalInputId:
    if on:
      __disable()
      for block: EditorBlock in attach_children:
        block.__disable()
    else:
      __enable()
      for block: EditorBlock in attach_children:
        block.__enable()

func generateBlockOpts():
  blockOptions.signalInputId = {"type": global.PromptTypes.int, "default": 0}