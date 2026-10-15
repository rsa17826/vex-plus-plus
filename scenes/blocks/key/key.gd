@icon("images/1.png")
extends EditorBlock
class_name BlockKey

var randOffset: float = 0.5
var following := false
var used := false
var holder: Player
## index of the player holding this key, used for saving
var pendingHolderIndex := -1
var holderIndex: int:
  get():
    return global.players.find(holder)
  set(val):
    pendingHolderIndex = val

func onSave() -> Array[String]:
  if following:
    return [
      "following",
      "thingThatMoves.global_position",
      "randOffset",
      "thingThatMoves.global_rotation",
      "holderIndex",
      "used"
    ]
  return ["following", "used"]

func on_body_entered(body: Node) -> void:
  if body is Player and not following and not thingThatMoves in body.keys:
    body.keys.push_front(thingThatMoves)
    holder = body
    following = true
    randOffset = global.randfrom(-10, 10)
    for thing in cloneEventsHere:
      thing.following = false

func on_respawn() -> void:
  used = false
  following = false
  thingThatMoves.position += unusedOffset
  thingThatMoves.global_rotation = 0
  unusedOffset = Vector2.ZERO
  thingThatMoves.position = Vector2.ZERO
  for p: Player in global.players:
    p.keys.erase(thingThatMoves)
  holder = null
  __enable()

func onDataLoaded() -> void:
  if used:
    __disable.call_deferred()
    return
  if following:
    holder = global.players[pendingHolderIndex]
    holder.keys.push_front(thingThatMoves)
    for thing in cloneEventsHere:
      thing.following = false

func onDelete():
  for p: Player in global.players:
    p.keys.erase(thingThatMoves)
