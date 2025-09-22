@icon("images/1.png")
extends EditorBlock
class_name BlockDonup

var falling := false

func on_respawn():
  falling = false

func onSave() -> Array[String]:
  return [
    "falling",
    "thingThatMoves.global_position",
    "thingThatMoves.vel",
    "thingThatMoves.startTime"
  ]