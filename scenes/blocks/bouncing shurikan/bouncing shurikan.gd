@icon("images/1.svg")
extends EditorBlock
class_name BlockBouncingShurikan

@export var sprite: Sprite2D

var ttmpos: Vector2:
  get():
    return thingThatMoves.global_position
  set(val):
    thingThatMoves.global_position = val
var ttmdir: Vector2:
  get():
    return thingThatMoves.dir
  set(val):
    thingThatMoves.dir = val

func onSave() -> Array[String]:
  return ["ttmpos", "ttmdir"]

func on_process(delta: float) -> void:
  spin(150, sprite)
