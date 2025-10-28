@icon("images/editorBar.png")
extends EditorBlock
class_name BlockPendulum

@export var bottomSprite: Sprite2D
@export var rotNode: Node2D
@export var cbody: Node2D

func on_physics_process(delta: float) -> void:
  spin(75, rotNode)
  bottomSprite.global_rotation = 0
  cbody.position = Vector2(0, 939).rotated(rotNode.global_rotation)
