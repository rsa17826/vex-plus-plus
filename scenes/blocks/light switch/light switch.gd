extends "res://scenes/blocks/editor.gd"

func on_body_entered(body: Node) -> void:
  if body == global.player:
    global.player.lightsOut = true