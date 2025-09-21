@icon("images/1.png")
extends EditorBlock
class_name BlockFalling

var ttmpos: Vector2:
  get():
    return thingThatMoves.global_position
  set(val):
    thingThatMoves.global_position = val
var ttmvel: Vector2:
  get():
    return thingThatMoves.vel
  set(val):
    thingThatMoves.vel = val
var ttmstartTime: float:
  get():
    return thingThatMoves.startTime
  set(val):
    thingThatMoves.startTime = val

var falling := false

func on_respawn():
  falling = false

func onSave() -> Array[String]:
  return ["falling", "ttmpos", "ttmvel", "ttmstartTime"]