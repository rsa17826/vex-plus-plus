@icon("images/1.png")
extends EditorBlock
class_name BlockPole

@export var timingIndicator: Node2D
func on_body_entered(body: Node) -> void:
  if body == global.player:
    if global.player.state == global.player.States.dead: return
    if global.player.state == global.player.States.swingingOnPole: return
    if global.player.get_node("anim").animation == "jumping off pole": return
    if global.player.activePole:
      global.player.activePole.root.timingIndicator.visible = false
    global.player.activePole = $collisionNode
    timingIndicator.visible = true
    timingIndicator.rotation_degrees = (-rotation_degrees) + 45
    global.player.state = global.player.States.swingingOnPole

func on_respawn():
  timingIndicator.visible = false
  $collisionNode.position = Vector2.ZERO