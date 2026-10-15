extends TextureRect

func _process(delta: float) -> void:
  # there is no player while a level is loading
  if not global.focusedPlayer: return
  visible = global.focusedPlayer.noclipEnabled
