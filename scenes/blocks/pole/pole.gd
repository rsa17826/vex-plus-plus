@icon("images/1.png")
extends EditorBlock
class_name BlockPole

@export var timingIndicator: Node2D

func on_body_entered(body: Node) -> void:
  if body is Player:
    if body.state == Player.States.dead: return
    if body.state == Player.States.swingingOnPole: return
    if body.inWaters: return
    if body.poleCooldown > 0: return
    if body.activePole and body.activePole != $collisionNode:
      body.activePole.root.timingIndicator.visible = false
    body.activePole = $collisionNode
    body.state = Player.States.swingingOnPole

func on_respawn():
  timingIndicator.visible = false
  for p: Player in global.players:
    if p.activePole == $collisionNode:
      p.activePole = null
      if p.state == Player.States.swingingOnPole:
        p.state = Player.States.falling
  $collisionNode.position = Vector2.ZERO
  await global.wait()
  timingIndicator.visible = false
  $collisionNode.position = Vector2.ZERO

func on_process(delta: float):
  var anyActive := false
  for p: Player in global.players:
    if p.activePole == $collisionNode:
      if _DISABLED:
        p.state = Player.States.falling
        p.activePole = null
      else:
        anyActive = true
  if not anyActive:
    timingIndicator.visible = false
