extends Camera2D

func _process(delta: float) -> void:
  var intendedPos = (global.focusedPlayer.camera.get_screen_center_position())
  global_position = intendedPos
  rotation = global.focusedPlayer.camera.rotation
