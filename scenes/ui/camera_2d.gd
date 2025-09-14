extends Camera2D

func _process(delta: float) -> void:
  var intendedPos = (global.player.get_node("Camera2D").get_screen_center_position())
  global_position = intendedPos