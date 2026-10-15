extends Camera2D

func _process(delta: float) -> void:
  # there is no player while a level is loading
  if not global.focusedPlayer: return
  var intendedPos = (global.focusedPlayer.camera.get_screen_center_position())
  global_position = intendedPos
  rotation = global.focusedPlayer.camera.rotation
