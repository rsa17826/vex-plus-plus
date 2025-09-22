@icon("images/1.png")
extends EditorBlock
class_name BlockPushableBox

func onSave() -> Array[String]:
  return ["thingThatMoves.global_position", "thingThatMoves.vel"]