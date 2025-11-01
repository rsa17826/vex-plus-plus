@icon("images/editorBar.png")
extends EditorBlock
class_name BlockCannon

@export var rotNode: Node2D

func on_body_entered(body: Node) -> void:
  if body is Player:
    if global.player.activeCannon and global.player.activeCannon == self: return
    # if global.player.activeCannon:
    #   global.player.activeCannon.top_level = false
    global.player.state = Player.States.inCannon
    global.player.activeCannon = self
    global.player.cannonRotationDelayFrames = 0.07

func on_respawn() -> void:
  # top_level = false
  rotNode.rotation_degrees = 0
