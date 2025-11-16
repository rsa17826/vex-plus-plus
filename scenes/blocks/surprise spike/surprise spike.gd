@icon("images/1.png")
extends EditorBlock
class_name BlockSurpriseSpike
@export var nodeToJump: Node2D
func on_respawn():
  thingThatMoves.position = Vector2.ZERO

func on_physics_process(delta: float) -> void:
  var stepSize = 42 * scale.y * 7
  # nodeToJump.position.y = global.animate(50 / (scale.y * 7), [
  nodeToJump.position.y = global.animate(50, [
    {
      "until": 50,
      "from": - stepSize,
      "to": stepSize
    },
    {
      "until": 100,
      "from": stepSize,
      "to": stepSize
    },
    {
      "until": 105,
      "from": stepSize,
      "to": - stepSize
    },
    {
      "until": 140,
      "from": - stepSize,
      "to": - stepSize
    },
  ])


func getDeathMessage(message: String, dir: Vector2) -> String:
  match dir:
    Vector2.UP:
      message += "got an unexpected spike to the head"
    Vector2.DOWN:
      message += "got an unexpected spike in the but"
    Vector2.LEFT, Vector2.RIGHT:
      message += "got unexpectedly penetrated by a spike"
    Vector2.ZERO:
      message += "got teleported into a spike"
  return message