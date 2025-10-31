@icon("images/1.png")
extends EditorBlock
class_name BlockMovingSpike
func on_respawn():
  thingThatMoves.position = Vector2.ZERO

func onSave() -> Array:
  return ["thingThatMoves.dir"]