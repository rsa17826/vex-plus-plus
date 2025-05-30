extends Area2D

func _on_body_exited(body: Node2D) -> void:
  pass # Replace with function body.

func _on_body_entered(body=null) -> void:
  body.root.respawn()
