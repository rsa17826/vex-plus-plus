extends SubViewportContainer

func _ready() -> void:
  global.ui.overlayRemovalHidersubViewportContainer = self
  get_child(0).world_2d = get_window().world_2d