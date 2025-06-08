extends "res://scenes/blocks/editor.gd"

@export_group("CANON")
func on_body_entered(body: Node) -> void:
  if body == global.player:
    global.player.state = global.player.States.inCannon
    global.player.global_position = ghostIconNode.global_position
    
func on_respawn() -> void:
  $collisionNode.position = Vector2.ZERO
