@icon("images/1.png")
extends EditorBlock
class_name BlockBuzsaw

func on_respawn() -> void:
  $collisionNode.position = Vector2.ZERO
