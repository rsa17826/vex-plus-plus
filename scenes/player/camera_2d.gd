extends Camera2D
func _physics_process(delta: float) -> void:
  if global.useropts.snapCameraToPixels:
    global_transform.origin = global_transform.origin.round()
