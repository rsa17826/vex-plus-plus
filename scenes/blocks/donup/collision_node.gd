extends CharacterBody2D

@export var root: EditorBlock

var speed = 2500
var startTime = 0

func on_physics_process(delta: float) -> void:
  if root.respawning: return
  if !root.falling: return
  if not startTime:
    startTime = global.tick
  velocity.y -= speed * delta
  velocity.y *= .95
  move_and_slide()
  if (global.tick - startTime) > 2:
    root.respawn()

func on_ready(first=false):
  startTime = 0
  velocity = Vector2(0, 0)
  global_position = root.startPosition

func on_respawn():
  startTime = 0
  process_mode = Node.PROCESS_MODE_DISABLED
  velocity = Vector2(0, 0)
  global_position = root.startPosition
  await global.wait()
  process_mode = Node.PROCESS_MODE_INHERIT
