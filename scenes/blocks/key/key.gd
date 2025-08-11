@icon("images/1.png")
extends EditorBlock
class_name BlockKey

var randOffset: float = 0.5
var following := false
func on_body_entered(body: Node) -> void:
  if body is Player and not following and not $collisionNode in global.player.keys:
    global.player.keys.push_front($collisionNode)
    # log.pp("key added", $collisionNode)
    following = true
    randOffset = global.randfrom(-10, 10)
    for thing in cloneEventsHere:
      thing.following = false

func on_respawn() -> void:
  following = false
  thingThatMoves.position += unusedOffset
  $collisionNode.global_rotation = 0
  unusedOffset = Vector2.ZERO
  $collisionNode.position = Vector2.ZERO
  if $collisionNode in global.player.keys:
    global.player.keys.erase($collisionNode)
  __enable()

func onDelete():
  if $collisionNode in global.player.keys:
    global.player.keys.erase($collisionNode)

func on_process(delta: float) -> void:
  if !following: return
  # $collisionNode.global_position = global.player.global_position