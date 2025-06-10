extends "res://scenes/blocks/editor.gd"

@export_group("WATER")
@export var sprite: Node2D
const MAX_REENTER_TIME = 7

var waterReenterTimer: float = 0

var playerInsideWater := false

var eletric := []

func on_respawn():
  eletric = []
  sprite.animation = "default"
  playerInsideWater = false
  waterReenterTimer = 0
  for area in $collisionNode.get_overlapping_areas():
    on_area_entered(area)

func on_physics_process(delta: float) -> void:
  # lower frame counters
  if waterReenterTimer > 0:
    waterReenterTimer -= delta * 60
    
  if eletric and self in global.player.inWaters:
    global.player.deathSources.append(self)
      
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
    
func on_area_exited(body: Node) -> void:
  if body.is_in_group("spark"):
    eletric.erase(body)
    sprite.animation = "eletric" if eletric else "default"

func on_area_entered(body: Node) -> void:
  if body.is_in_group("spark"):
    eletric.append(body)
    sprite.animation = "eletric" if eletric else "default"