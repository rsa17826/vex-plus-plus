@icon("images/1.png")
extends EditorBlock
class_name BlockJumpRefresher

func on_body_entered(body: Node) -> void:
  if body is Player:
    body.remainingJumpCount = body.MAX_JUMP_COUNT