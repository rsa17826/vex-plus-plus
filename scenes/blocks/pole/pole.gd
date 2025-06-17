@icon("images/1.png")
extends EditorBlock
class_name BlockPole

@export var timingIndicator: Node2D

func on_body_entered(body: Node) -> void:
  if body == global.player:
    timingIndicator.visible = true
    timingIndicator.rotation_degrees = (-rotation_degrees) + 45
    if global.player.state == global.player.States.dead: return
    if global.player.state == global.player.States.swingingOnPole: return
    if global.player.get_node("anim").animation == "jumping off pole": return
    if global.player.activePole and global.player.activePole != $collisionNode:
      global.player.activePole.root.timingIndicator.visible = false
    global.player.activePole = $collisionNode
    global.player.state = global.player.States.swingingOnPole

func on_respawn():
  timingIndicator.visible = false
  $collisionNode.position = Vector2.ZERO
  await global.wait()
  timingIndicator.visible = false
  $collisionNode.position = Vector2.ZERO
  
func on_process(delta: float):
  if global.player.activePole == $collisionNode:
    if _DISABLED:
      timingIndicator.visible = false
      global.player.state = global.player.States.falling
      global.player.activePole = null
  else:
    timingIndicator.visible = false