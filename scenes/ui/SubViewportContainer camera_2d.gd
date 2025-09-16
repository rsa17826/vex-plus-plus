extends Camera2D

func _process(delta: float) -> void:
  var intendedPos = (global.player.camera.get_screen_center_position())
  global_position = intendedPos
  rotation = global.player.camera.rotation