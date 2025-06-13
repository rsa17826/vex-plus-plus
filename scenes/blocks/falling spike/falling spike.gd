extends "res://scenes/blocks/editor.gd"

@export_group("FALLING SPIKE")
@export var nodeToFall: Node2D

var respawnTimer = 0
const RESPAWN_TIME = 40
const speed = 3500.0
var onusedOffset = Vector2.ZERO

func on_respawn():
  falling = false
  position = startPosition
  nodeToFall.position = Vector2.ZERO
  nodeToFall.position += onusedOffset
  onusedOffset = Vector2.ZERO
  # $Node2D/collisionNode.position = Vector2(0, 13)

var falling: bool = false

func on_physics_process(delta: float) -> void:
  if respawnTimer > 0:
    respawning = 2
    respawnTimer -= delta * 60
    if respawnTimer < 0:
      respawning = 0
      respawnTimer = 0
    thingThatMoves.scale = global.rerange(respawnTimer, RESPAWN_TIME, 0, Vector2(.1, .1), Vector2(1, 1))
    return
  if falling:
    nodeToFall.position += Vector2(0, -speed * delta)

func _on_floor_detection_body_entered(body: Node2D) -> void:
  %"attach detector".following = true
  respawnTimer = RESPAWN_TIME
  on_respawn()
