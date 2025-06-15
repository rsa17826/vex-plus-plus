@icon("images/1.png")
extends EditorBlock
class_name BlockLeFtRight

func _physics_processLEFTRIGHT(delta: float) -> void:
  thingThatMoves.global_position.x = startPosition.x - sin(global.tick * 1.5) * 200
