extends "res://scenes/blocks/editor.gd"

@export_group("PORTAL")

func on_body_exited(body: Node) -> void:
  if global.lastPortal == self:
    global.lastPortal = null

func on_respawn() -> void:
  if global.lastPortal == self:
    global.lastPortal = null
  $collisionNode.position = Vector2.ZERO

func on_body_entered(body: Node) -> void:
  if body == global.player and global.lastPortal != self:
    for portal in get_tree().get_nodes_in_group("portal"):
      if portal == self: continue
      if portal.selectedOptions.portalId == selectedOptions.exitId:
        global.lastPortal = portal
        global.player.global_position = portal.global_position

func generateBlockOpts():
  blockOptions.portalId = {"type": global.PromptTypes.int, "default": 0}
  blockOptions.exitId = {"type": global.PromptTypes.int, "default": 0}