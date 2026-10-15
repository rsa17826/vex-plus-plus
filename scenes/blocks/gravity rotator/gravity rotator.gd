@icon("images/1.png")
extends EditorBlock
class_name BlockGravityRotator

func on_body_entered(body: Node2D) -> void:
  if body is not Player: return
  var lastUpDir = body.up_direction
  body.up_direction = global.clearLow(Vector2.DOWN.rotated(rotation + deg_to_rad(0)))
  if lastUpDir == body.up_direction: return
  body.slowCamRot = true
  global.gravChanged.emit(body, lastUpDir, body.up_direction)
