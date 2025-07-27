@icon("images/1.png")
extends EditorBlock
class_name BlockButtonDeactivatedWall

func on_respawn() -> void:
  global.onSignalChanged(on_button_activated)

func on_button_activated(id, btn):
  if !selectedOptions.signalInputId: return
  if id == selectedOptions.signalInputId:
    __disable.call_deferred()
    for block: EditorBlock in attach_children:
      block.__disable.call_deferred()

func on_button_deactivated(id, btn):
  if !selectedOptions.signalInputId: return
  if id == selectedOptions.signalInputId:
    __enable.call_deferred()
    for block: EditorBlock in attach_children:
      block.__enable.call_deferred()

func generateBlockOpts():
  blockOptions.signalInputId = {"type": global.PromptTypes.int, "default": 0}