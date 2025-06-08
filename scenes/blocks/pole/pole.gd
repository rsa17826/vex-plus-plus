extends "res://scenes/blocks/editor.gd"

# POLE
@export_group("POLE")
func on_body_entered(body: Node) -> void:
  if body == global.player:
    if global.player.state == global.player.States.swingingOnPole: return
    if global.player.get_node("anim").animation == "jumping off pole": return
    global.player.state = global.player.States.swingingOnPole
    global.player.activePole = self