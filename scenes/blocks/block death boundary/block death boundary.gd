extends Area2D

func _on_body_exited(body: Node2D) -> void:
  pass # Replace with function body.

func _on_body_entered(body: Node2D) -> void:
  log.pp(body)
  if body.is_in_group("entity"):
    body.root.respawn()
