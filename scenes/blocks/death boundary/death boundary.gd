@icon("images/1.png")
extends EditorBlock
class_name BlockDeathBoundary

func getDeathMessage(message: String, dir: Vector2) -> String:
  match dir:
    Vector2.UP:
      message += "flew to close to the sun"
    Vector2.DOWN:
      message += "fell out of the world"
    Vector2.LEFT, Vector2.RIGHT:
      message += "walked out of bounds"
    Vector2.ZERO:
      message += "got teleported out of bounds"
  return message