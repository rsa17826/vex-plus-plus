@icon("images/1.png")
extends EditorBlock
class_name BlockButtonDeactivatedWall

var activeBtns: Array[EditorBlock] = []

func on_respawn() -> void:
  if self not in global.buttonWalls:
    global.buttonWalls.append(self )

func on_button_activated(id, btn):
  if !selectedOptions.buttonId: return
  if id == selectedOptions.buttonId:
    if btn not in activeBtns:
      activeBtns.append(btn)
    if activeBtns:
      __disable.call_deferred()
func on_button_deactivated(id, btn):
  if !selectedOptions.buttonId: return
  if id == selectedOptions.buttonId:
    if btn in activeBtns:
      activeBtns.erase(btn)
    if !activeBtns:
      __enable.call_deferred()

func generateBlockOpts():
  blockOptions.buttonId = {"type": global.PromptTypes.int, "default": 0}