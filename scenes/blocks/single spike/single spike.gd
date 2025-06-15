@icon("images/1.png")
extends EditorBlock
class_name BlockSingleSpike

func on_respawn():
  $collisionNode.position = Vector2.ZERO