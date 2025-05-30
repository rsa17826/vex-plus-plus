extends Area2D

func _on_body_exited(body: Node2D) -> void:
  pass # Replace with function body.

func _on_body_entered(body: Node2D) -> void:
  if body == global.player:
    global.player.gravState = global.player.GravStates.normal
  else:
    if 'root' not in body:
      log.pp(body, body.get_parent().texture.resource_path, body.get_parent().get_parent())
      breakpoint
    else:
      body.root.respawn()
