@icon("images/1.png")
extends EditorBlock
class_name BlockKey

var randOffset: float = 0.5
var following := false
func on_body_entered(body: Node) -> void:
  if body == global.player and not following and not $collisionNode in global.player.keys:
    global.player.keys.push_front($collisionNode)
    log.pp("key added", $collisionNode)
    following = true
    randOffset = global.randfrom(-10, 10)

func on_respawn() -> void:
  following = false
  $collisionNode.position = Vector2.ZERO
  if $collisionNode in global.player.keys:
    global.player.keys.erase($collisionNode)
  __enable()
  
func on_process(delta: float) -> void:
  if !following: return
  # $collisionNode.global_position = global.player.global_position