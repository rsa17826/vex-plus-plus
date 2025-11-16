@icon("images/editorBar.png")
extends EditorBlock

var respawnTimer = 0
const RESPAWN_TIME = 150
var onCooldown := false

@export var sprite: AnimatedSprite2D

var fallingNodes := []

var falling = false

@onready var spikesToClone = [%up, %down, %left, %right]
var timeSinceLastRespawn := 0
func playerDetected():
  for nodeToClone in spikesToClone:
    var node = nodeToClone.duplicate()
    nodeToClone.visible = false
    nodeToClone.get_node('CollisionShape2D').disabled = true
    node.get_node('CollisionShape2D').disabled = false
    node.falling = true
    add_child(node, true)
    fallingNodes.append(node)
  falling = true
  onCooldown = true
  sprite.play()

func on_respawn():
  falling = false
  timeSinceLastRespawn = 3
  for node in fallingNodes.filter(global.isAlive):
    node.queue_free()
  for node in spikesToClone:
    node.get_node('CollisionShape2D').disabled = false
    node.visible = true
  fallingNodes = []
  position = startPosition
  onCooldown = false
  sprite.stop()

func _on_animated_sprite_2d_animation_looped() -> void:
  for node in spikesToClone:
    node.get_node('CollisionShape2D').disabled = false
    node.visible = true
    falling = false
  onCooldown = false
  sprite.stop()

func on_physics_process(delta: float) -> void:
  if timeSinceLastRespawn > 0:
    timeSinceLastRespawn -= 1
  if not falling:
    timeSinceLastRespawn = 3

func getDeathMessage(message: String, dir: Vector2) -> String:
  if timeSinceLastRespawn > 0:
    match dir:
      Vector2.UP:
        message += "jumped into a quad falling spike"
      Vector2.DOWN:
        message += "jumped on a quad falling spike"
      Vector2.LEFT, Vector2.RIGHT:
        message += "walked into a quad falling spike"
      Vector2.ZERO:
        message += "got teleported into a quad falling spike"
  else:
    match dir:
      Vector2.UP:
        message += "jumped into a falling spike"
      Vector2.DOWN:
        message += "fell onto a falling spike"
      Vector2.LEFT, Vector2.RIGHT:
        message += "walked into a falling spike"
      Vector2.ZERO:
        message += "got hit by a falling spike"
  return message