@icon("images/1.svg")
extends EditorBlock
class_name BlockBouncingShurikan

@export var sprite: Sprite2D

func onSave() -> Array[String]:
  return ["thingThatMoves.global_position", "thingThatMoves.dir"]

func on_process(delta: float) -> void:
  spin(300, sprite)

func getDeathMessage(message: String, dir: Vector2) -> String:
  match dir:
    Vector2.UP:
      message += "jumped into a bouncing shuriken"
    Vector2.DOWN:
      message += "fell onto a bouncing shuriken"
    Vector2.LEFT, Vector2.RIGHT:
      message += "walked into a bouncing shuriken"
    Vector2.ZERO:
      message += "had a bouncing shuriken bounce into them"
  return message