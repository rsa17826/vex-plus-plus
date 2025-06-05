extends "res://scenes/blocks/editor.gd"

@export_group("FALLING SPIKE")
@export var nodeToFall: Node2D

var respawnTimer = 0
const RESPAWN_TIME = 40
const speed = 3500.0

func on_respawn():
  falling = false
  $Node2D.position = Vector2.ZERO
  position = startPosition
  # $Node2D/collisionNode.position = Vector2(0, 13)

var falling: bool = false

func on_physics_process(delta: float) -> void:
  if respawnTimer > 0:
    respawning = 2
    respawnTimer -= delta * 60
    if respawnTimer < 0:
      respawning = 0
      respawnTimer = 0
    scale = global.rerange(respawnTimer, RESPAWN_TIME, 0, Vector2(.1, .1), Vector2(1, 1)) / 7
    return
  if falling:
    $Node2D.position += Vector2(0, -speed * delta)

func _on_floor_detection_body_entered(body: Node2D) -> void:
  %"attach detector".enableAllGroups()
  respawnTimer = RESPAWN_TIME
  on_respawn()
