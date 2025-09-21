@icon("images/1.png")
extends EditorBlock
class_name BlockBouncingBuzzaw

var ttmpos:
  get():
    return thingThatMoves.global_position
  set(val):
    thingThatMoves.global_position = val
var ttmvel:
  get():
    return thingThatMoves.velocity
  set(val):
    thingThatMoves.velocity = val

func onSave() -> Array[String]:
  return ["ttmpos", "ttmvel"]