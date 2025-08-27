@icon("images/1.png")
extends EditorBlock
class_name BlockPole

@export var timingIndicator: Node2D

func on_body_entered(body: Node) -> void:
  if body is Player:
    if global.player.state == global.player.States.dead: return
    if global.player.state == global.player.States.swingingOnPole: return
    if global.player.inWaters: return
    if global.player.poleCooldown: return
    # if global.player.get_node("anim").animation == "jumping off pole": return
    if global.player.activePole and global.player.activePole != $collisionNode:
      global.player.activePole.root.timingIndicator.visible = false
    global.player.activePole = $collisionNode
    global.player.state = global.player.States.swingingOnPole

func on_respawn():
  timingIndicator.visible = false
  if global.player.activePole == $collisionNode:
    global.player.activePole = null
    if global.player.state == global.player.States.swingingOnPole:
      global.player.state = global.player.States.falling
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