@icon("images/1.png")
extends EditorBlock
class_name BlockGrowingBlock

@export var anim: AnimatedSprite2D

func on_physics_process(delta: float) -> void:
  var size = global.sinFrom(1, 2, global.tick, 1.3)
  thingThatMoves.scale = startScale * size * 7
