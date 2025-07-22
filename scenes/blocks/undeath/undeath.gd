@icon("images/1.png")
extends EditorBlock
class_name BlockUndeath

func on_body_entered(body: Node2D) -> void:
  log.pp(body, body is Player)
  if body is Player:
    body.state = body.States.falling