@icon("images/editorBar.png")
extends EditorBlock

var respawnTimer = 0
const RESPAWN_TIME = 150
var onCooldown := false

@export var sprite: AnimatedSprite2D

var fallingNodes := []

@onready var spikesToClone = [%up, %down, %left, %right]

func playerDetected():
  for nodeToClone in spikesToClone:
    var node = nodeToClone.duplicate()
    nodeToClone.visible = false
    nodeToClone.get_node('CollisionShape2D').disabled = true
    node.get_node('CollisionShape2D').disabled = false
    node.falling = true
    add_child(node, true)
    fallingNodes.append(node)
  onCooldown = true
  sprite.play()

func on_respawn():
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
  onCooldown = false
  sprite.stop()
