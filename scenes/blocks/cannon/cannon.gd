@icon("images/1.png")
extends EditorBlock
class_name BlockCannon

func on_body_entered(body: Node) -> void:
  if body == global.player:
    global.player.state = global.player.States.inCannon
    global.player.global_position = ghostIconNode.global_position
    
func on_respawn() -> void:
  $collisionNode.position = Vector2.ZERO
