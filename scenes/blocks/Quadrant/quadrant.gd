@icon("images/editorBar.png")
extends EditorBlock
class_name BlockQuadrant

@export var nodeToSpin: Node2D

func on_physics_process(delta: float) -> void:
  spin(150, nodeToSpin)

func on_respawn() -> void:
  $collisionNode.position = Vector2.ZERO
  nodeToSpin.rotation = 0
