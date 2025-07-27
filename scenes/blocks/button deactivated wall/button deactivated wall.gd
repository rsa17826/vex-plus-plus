@icon("images/1.png")
extends EditorBlock
class_name BlockButtonDeactivatedWall

func on_respawn() -> void:
  global.onSignalChanged(on_signal_changed)

func on_signal_changed(id, on):
  if id == selectedOptions.signalInputId:
    if on:
      __disable.call_deferred()
      for block: EditorBlock in attach_children:
        block.__disable.call_deferred()
    else:
      __enable.call_deferred()
      for block: EditorBlock in attach_children:
        block.__enable.call_deferred()

func generateBlockOpts():
  blockOptions.signalInputId = {"type": global.PromptTypes.int, "default": 0}