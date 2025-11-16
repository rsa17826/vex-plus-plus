@icon("images/1.png")
extends EditorBlock
class_name BlockSingleSpike

func on_respawn():
  thingThatMoves.position = Vector2.ZERO

func getDeathMessage(message: String, dir: Vector2) -> String:
  match dir:
    Vector2.UP:
      message += "jumped into a spike"
    Vector2.DOWN:
      message += "got popped on a spike"
    Vector2.LEFT, Vector2.RIGHT:
      message += "walked right into a spike"
    Vector2.ZERO:
      message += "got teleported into a spike"
  return message