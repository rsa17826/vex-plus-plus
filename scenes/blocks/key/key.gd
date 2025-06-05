extends "res://scenes/blocks/editor.gd"

@export_group("KEY")
var following := false
func on_body_entered(body: Node) -> void:
  if body == global.player and not following and not $collisionNode in global.player.keys:
    global.player.keys.append($collisionNode)
    log.pp("key added", $collisionNode)
    following = true

func on_respawn() -> void:
  following = false
  $collisionNode.position = Vector2.ZERO
  if $collisionNode in global.player.keys:
    global.player.keys.erase($collisionNode)

func on_process(delta: float) -> void:
  if !following: return
  $collisionNode.global_position = global.player.global_position