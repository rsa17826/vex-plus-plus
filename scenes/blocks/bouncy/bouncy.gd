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
  original_contact_position = global.player.global_position

  var radrot := deg_to_rad(startRotation_degrees)
  var extraRot = global.player.angle_distance(radrot, global.player.global_rotation)
    
  var playerGhost: Node2D = global.player.get_parent().ghost
  var playerGhostSize: Vector2 = playerGhost.get_texture().get_size() * playerGhost.scale

  # Calculate the half sizes
  var half_player_height = abs(playerGhostSize.y / 2)
  var half_rotated_height = abs(playerGhostSize.rotated(extraRot).y / 2)

  # Calculate the offset needed to position the player directly above the block
  var offset_vector = Vector2(0, half_player_height - half_rotated_height).rotated(-radrot)
  original_contact_position += offset_vector

func on_respawn():
  bounceState = 0
  bouncing = false
  bounceForce = 0

var original_contact_position: Vector2

func on_process(delta: float) -> void:
  if respawning: return
  if bouncing:
    var sizeInPx := ghostIconNode.texture.get_size()
    var radrot := deg_to_rad(startRotation_degrees)
    if not bounceForce:
      bounceForce = (scale.y * 7) * -2900

    if bounceState < 100:
      # Increase the bounce state more the farther from 50 the state is
      bounceState += max(0.2, abs(bounceState - 50) / 10.0) * delta * 300 / (scale.y * 21)
    else:
      # When the bouncing animation is done, start bouncing the player
      global.player.vel.bounce = Vector2(0, bounceForce).rotated(radrot)
      global.player.justAddedVels.bounce = 3
      global.player.state = global.player.States.jumping
      respawn()

    var size: Vector2 = ghost.texture.get_size() * startScale

    if bounceState <= 50:
      # Start by going down
      global_position = startPosition + Vector2(0, global.rerange(bounceState, 0, 50, 0, (size.y / 4.0))).rotated(radrot)
      scale.y = global.rerange(bounceState, 0, 50, startScale.y, startScale.y / 2)
    else:
      # Then go back up
      scale.y = global.rerange(bounceState, 50, 100, startScale.y / 2, startScale.y)
      global_position = startPosition + Vector2(0, global.rerange(bounceState, 100, 50, 0, (size.y / 4.0))).rotated(radrot)

    var node_size := sizeInPx * scale

    var offset = Vector2(0, node_size.y)
    offset = offset.rotated(radrot)

    global.player.global_position = (original_contact_position - offset) + Vector2(0, (sizeInPx * startScale).y).rotated(radrot)
    global.player.setRot(radrot)
    global.player.updateCamLockPos()
