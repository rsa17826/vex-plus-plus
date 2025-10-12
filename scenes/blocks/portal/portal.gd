@icon("images/1.png")
extends EditorBlock
class_name BlockPortal

func on_body_exited(body: Node) -> void:
  if global.lastPortal == self:
    global.lastPortal = null

func on_respawn() -> void:
  if global.lastPortal == self:
    global.lastPortal = null
  if self not in global.portals:
    global.portals.append(self)

func on_body_entered(body: Node) -> void:
  if body is Player:
    if global.lastPortal == self: return
    if selectedOptions.exitId == 0: return
    for portal in global.portals:
      if portal == self: continue
      if portal.selectedOptions.portalId == selectedOptions.exitId:
        global.lastPortal = portal
        global.player.global_position = portal.global_position
        global.player.activePulley = null
        global.player.activePole = null
        global.player.state = global.player.States.falling

func generateBlockOpts():
  blockOptions.exitId = {"type": global.PromptTypes.int, "default": 0}
  blockOptions.portalId = {"type": global.PromptTypes.int, "default": 0}