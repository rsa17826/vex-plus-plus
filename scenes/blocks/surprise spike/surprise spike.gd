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
