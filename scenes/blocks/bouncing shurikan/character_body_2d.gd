extends CharacterBody2D
@export var root: EditorBlock

const SPEED = 30.0

var dir := Vector2(1, 1)

func on_respawn():
  dir = Vector2(1, 1)

func on_physics_process(delta: float) -> void:
  velocity = dir * SPEED
  if move_and_slide():
    var ang = get_last_slide_collision().get_normal()
    log.pp(ang, dir)
    if ang.x == -1:
      dir.x = -1
    if ang.x == 1:
      dir.x = 1
    if ang.y == 1:
      dir.y = 1
    if ang.y == -1:
      dir.y = -1