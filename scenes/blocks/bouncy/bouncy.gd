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

  # Calculate the offset needed to position the player directly above the block
  var offset_vector = ((playerGhostSize/ 2) - (playerGhostSize.rotated(extraRot) / 2)).rotated(-radrot)

  # Apply the offset to the original contact position
  original_contact_position += offset_vector

  # Log the adjusted position for debugging
  log.pp(offset_vector, startRotation_degrees)

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

    # Adjust the position based on the current rotation
    var node_pos := ghostIconNode.global_position
    var node_size := sizeInPx * scale
    var top_edge := node_pos.y - node_size.y / 2 # Correctly calculate the top edge

    var playerGhost: Node2D = global.player.get_parent().ghost
    var playerGhostSize: Vector2 = playerGhost.get_texture().get_size() * playerGhost.scale

    # Calculate the offset based on the block's rotation
    var offset = Vector2(0, node_size.y)
    offset = offset.rotated(radrot) # Rotate the offset to match the block's rotation

    # Calculate the new position based on the original contact position
    global.player.global_position = (original_contact_position - offset) + Vector2(0, (sizeInPx * startScale).y).rotated(radrot)
    global.player.setRot(radrot)
    global.player.updateCamLockPos()

    # Adjust the player's position based on the block's rotation
    # global.player.global_position.x += cos(radrot) * offset.x - sin(radrot) * offset.y
    # global.player.global_position.y += sin(radrot) * offset.x + cos(radrot) * offset.y
