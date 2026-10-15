extends TextureRect

func _process(delta: float) -> void:
  visible = global.focusedPlayer.noclipEnabled
