@icon("images/1.png")
extends EditorBlock
class_name BlockBouncy

var bouncing := false
var bouncer: Player
var bounceState: float = 0
var bounceForce: float = 0

# @export var animated: Node2D

func start(p: Player) -> void:
  if bouncing: return
  if respawnTimer > 0: return
  bouncing = true
  bouncer = p
  bounceState = 0
  p.state = Player.States.bouncing
  original_contact_position = p.global_position

  var radrot := deg_to_rad(startRotation_degrees)
  # # log.pp(p.defaultAngle)
  # var extraRot = p.angle_distance(radrot, p.global_rotation)

  var playerGhost: Node2D = p.root.ghost
  var playerGhostSize: Vector2 = playerGhost.get_texture().get_size() * playerGhost.scale

  # # Calculate the half sizes
  var half_player_height = abs(playerGhostSize.y / 2)
  # var half_rotated_height = abs(playerGhostSize.rotated(extraRot).y / 2)

  # # Calculate the offset needed to position the player directly above the block
  # var offset_vector = Vector2(0, half_player_height - half_rotated_height).rotated(-radrot)
  # log.pp(p.defaultAngle, extraRot, radrot)
  # log.pp(offset_vector, half_player_height)
  # log.err(extraRot, radrot)
  original_contact_position -= Vector2(0, half_player_height).rotated(radrot)

var respawnTimer = 0

func on_respawn():
  respawnTimer = 0
  bounceState = 0
  bouncing = false
  bounceForce = 0
  bouncer = null

var original_contact_position: Vector2

func onPathMove(dist):
  original_contact_position += dist

func on_process(delta: float) -> void:
  scale = startScale
  position = startPosition
  if respawnTimer > 0:
    respawnTimer -= delta * 60
    if respawnTimer <= 0:
      on_respawn.call_deferred()
    return
  if respawning: return
  if bouncing and bouncer.state == Player.States.dead:
    on_respawn()
    return
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
      bouncer.vel.bounce = Vector2(0, bounceForce).rotated(radrot).rotated(-bouncer.defaultAngle)
      bouncer.justAddedVels.bounce = 3
      bouncer.state = Player.States.jumping
      respawnTimer = 10

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

    bouncer.global_position = (original_contact_position - offset) + Vector2(0, (sizeInPx * startScale).y).rotated(radrot)
    bouncer.setRot(radrot)
    bouncer.updateCamLockPos()
