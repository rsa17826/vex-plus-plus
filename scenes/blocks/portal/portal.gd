@icon("images/1.png")
extends EditorBlock
class_name BlockPortal

func on_body_exited(body: Node) -> void:
  if body is Player and body.lastPortal == self:
    body.lastPortal = null

func on_respawn() -> void:
  for p: Player in global.players:
    if p.lastPortal == self:
      p.lastPortal = null
  if self not in global.portals:
    global.portals.append(self)

func on_body_entered(body: Node) -> void:
  if body is Player:
    if body.lastPortal == self: return
    if selectedOptions.exitId == 0: return
    for portal in global.portals:
      if portal == self: continue
      if portal.selectedOptions.portalId == selectedOptions.exitId:
        body.lastPortal = portal
        body.global_position = portal.global_position
        body.activePulley = null
        body.activePole = null
        body.state = Player.States.falling

func generateBlockOpts():
  blockOptions.exitId = {"type": global.PromptTypes.int, "default": 0}
  blockOptions.portalId = {"type": global.PromptTypes.int, "default": 0}
