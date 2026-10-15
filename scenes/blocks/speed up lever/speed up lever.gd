@icon("images/1.png")
extends EditorBlock
class_name BlockSpeedUpLever

var collidingPlayers: Array[Player] = []

func on_respawn():
  collidingPlayers = []

func on_body_entered(body: Node) -> void:
  if body is Player:
    if body not in collidingPlayers:
      collidingPlayers.append(body)
func on_body_exited(body: Node) -> void:
  if body is Player:
    collidingPlayers.erase(body)

func _input(event: InputEvent) -> void:
  if Input.is_action_just_pressed("down"):
    for p: Player in collidingPlayers.duplicate():
      if p.state != Player.States.pullingLever \
      and p.is_on_floor() \
      and not p.inWaters:
        p.state = Player.States.pullingLever
        p.speedLeverActive = !p.speedLeverActive
        if p == global.focusedPlayer:
          if p.speedLeverActive:
            global.ui.gravityChange.activate(global.ui.gravityChange.color.green)
          else:
            global.ui.gravityChange.deactivate(global.ui.gravityChange.color.green)
