@icon("images/editorBar.png")
extends EditorBlock
class_name BlockPendulum

@export var col: CollisionShape2D
@export var bot: Sprite2D

func on_process(delta: float) -> void:
  spin(75, thingThatMoves)
  spin(-75, col)
  spin(-75, bot)