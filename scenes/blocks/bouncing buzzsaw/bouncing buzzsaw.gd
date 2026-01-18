@icon("images/1.png")
extends EditorBlock
class_name BlockBouncingBuzzaw

func onSave() -> Array[String]:
  return ["thingThatMoves.global_position", "thingThatMoves.velocity", "thingThatMoves.speed"]

func getDeathMessage(message: String, dir: Vector2) -> String:
  match dir:
    Vector2.UP:
      message += "jumped into a buzzsaw as it tried to fall on their head"
    Vector2.DOWN:
      message += "had a buzzsaw fall up just to kill them"
    Vector2.LEFT, Vector2.RIGHT:
      message += "walked into a falling buzzsaw"
    Vector2.ZERO:
      message += "had a buzzsaw fall on their head"
  return message