@icon("images/1.png")
extends EditorBlock
class_name BlockKey

var randOffset: float = 0.5
var following := false
var used := false

var ttmpos: Vector2:
  get():
    return thingThatMoves.global_position
  set(val):
    thingThatMoves.global_position = val
var ttmrot: float:
  get():
    return thingThatMoves.global_rotation
  set(val):
    thingThatMoves.global_rotation = val

func onSave() -> Array[String]:
  if following:
    return ["following", "ttmpos", "randOffset", "ttmrot", "used"]
  return ["following", "used"]

func on_body_entered(body: Node) -> void:
  if body is Player and not following and not thingThatMoves in global.player.keys:
    global.player.keys.push_front(thingThatMoves)
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
  if thingThatMoves in global.player.keys:
    global.player.keys.erase(thingThatMoves)
  __enable()

func onDataLoaded() -> void:
  if used:
    __disable.call_deferred()
    return
  if following:
    global.player.keys.push_front(thingThatMoves)
    for thing in cloneEventsHere:
      thing.following = false

func onDelete():
  if thingThatMoves in global.player.keys:
    global.player.keys.erase(thingThatMoves)