extends CharacterBody2D

@export var root: EditorBlock

var vel := Vector2Grav.ZERO

var speed = 2500
var startTime = 0

func on_physics_process(delta: float) -> void:
  up_direction = global.player.up_direction
  if root.respawning: return
  if !root.falling: return
  if not startTime:
    startTime = global.tick
  vel.y += speed * delta
  vel.y *= .95
  vel.x = 0
  velocity = vel.vector
  move_and_slide()
  if (global.tick - startTime) > 2:
    root.respawn()

func on_ready(first=false):
  startTime = 0
  vel = Vector2Grav.new(0, 0)
  global_position = root.startPosition

func on_respawn():
  startTime = 0
  process_mode = Node.PROCESS_MODE_DISABLED
  vel = Vector2Grav.new(0, 0)
  global_position = root.startPosition
  await global.wait()
  process_mode = Node.PROCESS_MODE_INHERIT
