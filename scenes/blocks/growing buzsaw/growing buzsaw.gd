@icon("images/1.png")
extends EditorBlock
class_name BlockGrowingBuzsaw

@export var nodeToScale: Node2D

func on_respawn():
  $collisionNode.position = Vector2.ZERO

func on_physics_process(delta):
  var s = ((sin(global.tick * .8) * 1.04) + 1.98)
  # log.pp(s, clamp(s, 1, 3))
  s = clamp(s, 1, 3)
  nodeToScale.scale = Vector2(s, s)