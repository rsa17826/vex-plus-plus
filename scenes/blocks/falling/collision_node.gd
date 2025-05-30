extends CharacterBody2D

@export var root: Node2D

var speed = 2500
func on_physics_process(delta: float) -> void:
  if root.respawning: return
  if !root.FALLING_falling: return
  velocity.y += speed * delta
  velocity.y *= .95
  # if is_on_ceiling() or global_position.y < root.startPosition.y:
  #   speed = 50
  move_and_slide()
  if velocity.y > 28000:
    root.respawn()
  # if is_on_floor():
  #   speed = -50

func postMovementStep():
  root.lastMovementStep /= 4

func on_ready(first=false):
  velocity = Vector2(0, 0)
  global_position = root.startPosition

func on_respawn():
  process_mode = Node.PROCESS_MODE_DISABLED
  velocity = Vector2(0, 0)
  global_position = root.startPosition
  await global.wait()
  process_mode = Node.PROCESS_MODE_INHERIT
