@icon("images/1.png")
extends EditorBlock
class_name BlockSpeedUpLever

var colliding := false

func on_respawn():
  colliding = false
  $collisionNode.position = Vector2.ZERO

func on_body_entered(body: Node) -> void:
  if body == global.player:
    colliding = true
func on_body_exited(body: Node) -> void:
  if body == global.player:
    colliding = false

func _input(event: InputEvent) -> void:
  if Input.is_action_just_pressed("down"):
    if colliding \
    and global.player.state != global.player.States.pullingLever \
    and global.player.is_on_floor() \
    and not global.player.inWaters:
      global.player.state = global.player.States.pullingLever
      global.player.speedLeverActive = !global.player.speedLeverActive