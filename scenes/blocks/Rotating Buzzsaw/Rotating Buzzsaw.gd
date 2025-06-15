@icon("images/1.png")
extends EditorBlock
class_name BlockRotatingBuzzsaw

@export var nodeToSpin: Node2D
func on_physics_process(delta: float) -> void:
  spin(300, nodeToSpin)
  
func on_respawn() -> void:
  $Node2D.position = Vector2.ZERO
  $Node2D/collisionNode.position = Vector2.ZERO
  nodeToSpin.rotation = 0
