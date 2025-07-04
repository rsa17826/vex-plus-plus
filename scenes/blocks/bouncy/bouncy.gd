@icon("images/1.png")
extends EditorBlock
class_name BlockBouncy

var bouncing := false
var bounceState: float = 0
var bounceForce: float = 0

func start() -> void:
  if bouncing: return
  bouncing = true
  bounceState = 0
  global.player.state = global.player.States.bouncing

func on_respawn():
  bounceState = 0
  bouncing = false
  bounceForce = 0

func on_process(delta: float) -> void:
  if respawning: return
  if bouncing:
    if not bounceForce:
      bounceForce = (scale.y * 7) * -2900
    if bounceState < 100:
      # increase the bounce state more the farther from 50 the state is
      bounceState += max(.2, abs(bounceState - 50) / 10.0) * delta * 300 / (scale.y * 21)
    else:
      # when the bouncing animation is done start bouncing the player
      global.player.vel.bounce = global.player.applyRot(Vector2(0, bounceForce))
      global.player.justAddedVels.bounce = 3
      global.player.state = global.player.States.jumping
      respawn()
    if bounceState <= 50:
      # start by going down
      var size: Vector2 = ghost.texture.get_size() * startScale
      global_position.y = global.rerange(bounceState, 0, 50, startPosition.y, startPosition.y + (size.y / 4.0))
      scale.y = global.rerange(bounceState, 0, 50, startScale.y, startScale.y / 2)
    else:
      # then go back up
      var size: Vector2 = ghost.texture.get_size() * startScale
      scale.y = global.rerange(bounceState, 50, 100, startScale.y / 2, startScale.y)
      global_position.y = global.rerange(bounceState, 100, 50, startPosition.y, startPosition.y + (size.y / 4.0))

    var node_pos := ghostIconNode.global_position
    var node_size := ghostIconNode.texture.get_size() * scale
    var top_edge := node_pos.y - node_size.y / 2

    var playerGhost: Node2D = global.player.get_parent().ghost
    var playerGhostSize: Vector2 = playerGhost.get_texture().get_size() * playerGhost.scale

    # move the player to the top center of the bouncy block
    global.player.global_position.y = top_edge - (playerGhostSize.y / 2)
    # global.player.global_position.x = node_pos.x