@icon("images/1.png")
extends EditorBlock

var respawnTimer = 0
const RESPAWN_TIME = 150
var falling: bool = false

const speed = 3500.0
var fallingNodes := []

@onready var spikes = [%up, %down, %left, %right]

func playerDetected():
  for nodeToFall in spikes:
    var node = nodeToFall.duplicate()
    node.visible = true
    fallingNodes.append(node)
  falling = true

func on_respawn():
  falling = false
  position = startPosition

func on_physics_process(delta: float) -> void:
  if respawnTimer > 0:
    respawning = 2
    respawnTimer -= delta * 60
    if respawnTimer < 0:
      respawning = 0
      respawnTimer = 0
    for nodeToFall in spikes:
      nodeToFall.scale = global.rerange(respawnTimer, RESPAWN_TIME, 0, Vector2(.1, .1), Vector2(1, 1))
    return
  if falling:
    for nodeToFall in fallingNodes:
      nodeToFall.position += Vector2(0, -speed * delta).rotated(nodeToFall.rotation)

func _on_floor_detection_body_entered(body: Node2D) -> void:
  if body.root is BlockBomb:
    body.root.explode()
  respawnTimer = RESPAWN_TIME
  on_respawn()
