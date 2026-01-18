@icon("images/1.png")
extends EditorBlock
class_name BlockBuzzsaw

func on_respawn() -> void:
  $collisionNode.position = Vector2.ZERO

func getDeathMessage(message: String, dir: Vector2) -> String:
  match dir:
    Vector2.UP:
      message += "jumped into a buzzsaw"
    Vector2.DOWN:
      message += "fell onto a buzzsaw"
    Vector2.LEFT, Vector2.RIGHT:
      message += "walked into a buzzsaw"
    Vector2.ZERO:
      message += "got teleported into a buzzsaw"
  return message