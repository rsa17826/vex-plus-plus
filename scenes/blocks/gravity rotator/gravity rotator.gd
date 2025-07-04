@icon("images/1.png")
extends EditorBlock
class_name BlockGravityRotator

func on_body_entered(body: Node2D) -> void:
  if body is Player:
    body.up_direction = Vector2.DOWN.rotated(rotation + deg_to_rad(0))
    body.slowCamRot = true