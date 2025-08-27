@icon("images/1.png")
extends EditorBlock
class_name BlockGravityRotator

func on_body_entered(body: Node2D) -> void:
  var lastUpDir = global.player.up_direction
  global.player.up_direction = global.clearLow(Vector2.DOWN.rotated(rotation + deg_to_rad(0)))
  if lastUpDir == global.player.up_direction:
    return
  log.pp(lastUpDir, global.player.up_direction, lastUpDir == global.player.up_direction)
  global.player.slowCamRot = true
  global.gravChanged.emit(lastUpDir, global.player.up_direction)