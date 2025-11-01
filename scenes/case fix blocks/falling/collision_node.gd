extends CharacterBody2D

@export var root: EditorBlock

var vel := Vector2.ZERO

var speed = 2500
var startTime: float = 0

func on_physics_process(delta: float) -> void:
  if root.respawning: return
  if !root.falling: return
  if not startTime:
    startTime = global.tick
  vel.y += speed * delta
  vel.y *= .95
  vel.x = 0
  velocity = global.player.applyRot(vel)
  move_and_slide()
  if (global.tick - startTime) > 2:
    root.isBeingMoved = true
    process_mode = Node.PROCESS_MODE_DISABLED
    await global.wait()
    var temp = root.attach_children.duplicate()
    root.respawn()
    root.attach_children = temp
    process_mode = Node.PROCESS_MODE_INHERIT
    root.__enable()

func on_respawn():
  if root.loadDefaultData:
    startTime = 0
    process_mode = Node.PROCESS_MODE_DISABLED
    vel = Vector2.ZERO
    global_position = root.startPosition
    await global.wait()
    process_mode = Node.PROCESS_MODE_INHERIT