@icon("images/1.png")
extends EditorBlock
class_name BlockScythe

@export var nodeToSpin: Node2D
func on_physics_process(delta: float) -> void:
  spin(-300, nodeToSpin)

func on_respawn() -> void:
  $collisionNode.position = Vector2.ZERO
  nodeToSpin.rotation = 0