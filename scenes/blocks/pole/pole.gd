extends "res://scenes/blocks/editor.gd"

# POLE
@export_group("POLE")
func on_body_entered(body: Node) -> void:
  if global.player.state != global.player.States.swingingOnPole:
    global.player.state = global.player.States.swingingOnPole
    global.player.activePole = self