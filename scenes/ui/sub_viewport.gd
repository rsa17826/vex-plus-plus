extends SubViewport
func _ready() -> void:
  world_2d = get_window().world_2d

func _process(delta: float) -> void:
  canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST