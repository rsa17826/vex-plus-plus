@icon("images/1.png")
extends EditorBlock
class_name BlockFallingSpike

@export var nodeToFall: Node2D

var respawnTimer = 0
const RESPAWN_TIME = 40
const speed = 3500.0

func on_respawn():
  falling = false
  position = startPosition
  nodeToFall.position = Vector2.ZERO
  nodeToFall.position += unusedOffset
  unusedOffset = Vector2.ZERO
  # $Node2D/collisionNode.position = Vector2(0, 13)

var falling: bool = false

func on_physics_process(delta: float) -> void:
  if respawnTimer > 0:
    respawning = 2
    respawnTimer -= delta * 60
    if respawnTimer <= 0:
      respawning = 0
      respawnTimer = 0
      $Node2D/collisionNode/CollisionShape2D.disabled = false
    else:
      $Node2D/collisionNode/CollisionShape2D.disabled = true
    thingThatMoves.scale = global.rerange(clamp(respawnTimer, 0, RESPAWN_TIME), RESPAWN_TIME, 0, Vector2(.1, .1), Vector2(1, 1))
    return
  if falling:
    nodeToFall.position += Vector2(0, -speed * delta)

func _on_floor_detection_body_entered(body: Node2D) -> void:
  if body.root is BlockBomb:
    body.root.explode()
  %"attach detector".following = true
  respawnTimer = RESPAWN_TIME
  on_respawn()

func generateBlockOpts():
  blockOptions.groupId = {"type": global.PromptTypes.int, "default": 0}
