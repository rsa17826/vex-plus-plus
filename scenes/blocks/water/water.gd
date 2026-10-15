@icon("images/1.png")
extends EditorBlock
class_name BlockWater

@export var sprite: Node2D
const MAX_REENTER_TIME = 7

var reenterTimers: Dictionary[Player, float] = {}

var playersInside: Array[Player] = []

func isPlayerInside(p: Player) -> bool:
  return p in playersInside

var electric := []

func on_respawn():
  electric = []
  sprite.animation = "default"
  playersInside = []
  reenterTimers = {}
  for area in $collisionNode.get_overlapping_areas():
    on_area_entered(area)

func on_physics_process(delta: float) -> void:
  for p: Player in global.players:
    if reenterTimers.get(p, 0.0) > 0:
      reenterTimers[p] -= delta * 60

    if electric and self in p.inWaters:
      p.deathSources.append(self)

    if p in playersInside:
      if self not in p.inWaters and reenterTimers.get(p, 0.0) <= 0:
        p.inWaters.append(self)
    elif self in p.inWaters:
      p.inWaters.erase(self)

func on_body_exited(body: Node) -> void:
  if body is Player:
    playersInside.erase(body)
    reenterTimers[body as Player] = MAX_REENTER_TIME

func on_body_entered(body: Node) -> void:
  if body is Player:
    if body not in playersInside:
      playersInside.append(body)

func on_area_exited(body: Node) -> void:
  if body.is_in_group("spark"):
    electric.erase(body)
    sprite.animation = "electric" if electric else "default"

func on_area_entered(body: Node) -> void:
  if body.is_in_group("spark"):
    electric.append(body)
    sprite.animation = "electric" if electric else "default"

func getDeathMessage(message: String, dir: Vector2) -> String:
  message += "decided to swin in electric water"
  return message
