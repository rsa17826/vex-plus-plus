@icon("images/1.png")
extends EditorBlock
class_name BlockBlockDeathBoundary

func on_body_entered(body: Node2D) -> void:
  if body is Player:
    body.gravState = body.GravStates.normal
    body.speedLeverActive = false
    for key in body.keys:
      key.root.respawn.call_deferred()
  else:
    # if 'root' not in body:
    #   log.pp(body, body.get_parent().texture.resource_path, body.get_parent().get_parent())
    #   breakpoint
    # else:
    body.root.respawn.call_deferred()
