extends "res://scenes/blocks/editor.gd"

@export_group("WATER")

const MAX_REENTER_TIME = 7

var waterReenterTimer: float = 0

var playerInsideWater := false

func on_physics_process(delta: float) -> void:
  # lower frame counters
  if waterReenterTimer > 0:
    waterReenterTimer -= delta * 60

  if playerInsideWater:
    if self not in global.player.inWaters and waterReenterTimer <= 0:
      global.player.inWaters.append(self)
  elif self in global.player.inWaters:
    global.player.inWaters.erase(self)

func on_body_exited(body: Node) -> void:
  if body == global.player:
    playerInsideWater = false
    waterReenterTimer = MAX_REENTER_TIME

func on_body_entered(body: Node) -> void:
  if body == global.player:
    playerInsideWater = true
