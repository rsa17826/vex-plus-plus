@icon("images/1.png")
extends EditorBlock
class_name BlockButtonDeactivatedWall

func on_respawn() -> void:
  if not global.onButtonActivated.is_connected(on_button_activated):
    global.onButtonActivated.connect(on_button_activated)
  if not global.onButtonDeactivated.is_connected(on_button_deactivated):
    global.onButtonDeactivated.connect(on_button_deactivated)

func on_button_activated(id, btn):
  if !selectedOptions.buttonId: return
  if id == selectedOptions.buttonId:
    __disable.call_deferred()
    for block: EditorBlock in attach_children:
      block.__disable.call_deferred()
        
func on_button_deactivated(id, btn):
  if !selectedOptions.buttonId: return
  if id == selectedOptions.buttonId:
    __enable.call_deferred()
    for block: EditorBlock in attach_children:
      block.__enable.call_deferred()

func generateBlockOpts():
  blockOptions.buttonId = {"type": global.PromptTypes.int, "default": 0}