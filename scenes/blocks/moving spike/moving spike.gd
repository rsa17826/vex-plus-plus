@icon("images/1.png")
extends EditorBlock
class_name BlockMovingSpike
func on_respawn():
  thingThatMoves.position = Vector2.ZERO

func onSave() -> Array:
  return ["thingThatMoves.dir"]

func getDeathMessage(message: String, dir: Vector2) -> String:
  match dir:
    Vector2.UP:
      message += "jumped into a spike"
    Vector2.DOWN:
      message += "jumped on a spike"
    Vector2.LEFT, Vector2.RIGHT:
      message += "walked into a spike"
    Vector2.ZERO:
      message += "let a spike walk into them"
  return message