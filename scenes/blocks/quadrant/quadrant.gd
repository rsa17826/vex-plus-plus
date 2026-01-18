@icon("images/editorBar.png")
extends EditorBlock
class_name BlockQuadrant

@export var nodeToSpin: Node2D

func on_physics_process(delta: float) -> void:
  spin(150, nodeToSpin)

func on_respawn() -> void:
  $collisionNode.position = Vector2.ZERO
  nodeToSpin.rotation = 0

func getDeathMessage(message: String, dir: Vector2) -> String:
  match dir:
    Vector2.UP:
      message += "jumped into a quadrant"
    Vector2.DOWN:
      message += "fell onto a quadrant"
    Vector2.LEFT, Vector2.RIGHT:
      message += "walked into a quadrant"
    Vector2.ZERO:
      message += "let a quadrant rotate into them"
  return message