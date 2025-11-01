@icon("images/1.png")
extends EditorBlock
class_name BlockBouncingBuzzaw

func onSave() -> Array[String]:
  return ["thingThatMoves.global_position", "thingThatMoves.velocity", "thingThatMoves.speed"]