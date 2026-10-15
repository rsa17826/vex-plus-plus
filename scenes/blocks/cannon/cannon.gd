@icon("images/editorBar.png")
extends EditorBlock
class_name BlockCannon

@export var rotNode: Node2D

func on_body_entered(body: Node) -> void:
  if body is Player:
    if body.activeCannon and body.activeCannon == self: return
    # if body.activeCannon:
    #   body.activeCannon.top_level = false
    body.state = Player.States.inCannon
    body.activeCannon = self
    body.cannonRotationDelayFrames = 0.07

func on_respawn() -> void:
  # top_level = false
  rotNode.rotation_degrees = 0
