extends "res://scenes/blocks/editor.gd"

@export_group("GRAVITY DOWN LEVER")
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
    if colliding and global.player.state != global.player.States.pullingLever:
      global.player.state = global.player.States.pullingLever
      if global.player.gravState == global.player.GravStates.down:
        global.player.gravState = global.player.GravStates.normal
      else:
        global.player.gravState = global.player.GravStates.down