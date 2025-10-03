extends CharacterBody2D

var speed = 50

@export var root: EditorBlock

func on_physics_process(delta: float) -> void:
  if root._DISABLED: return
  if root.respawning: return
  velocity.y += speed
  velocity.y *= .95
  if is_on_ceiling() or global_position.y < root.startPosition.y:
    speed = 50
  move_and_slide()
  %CharacterBody2D.global_position = global_position
  if is_on_floor():
    speed = -50
func on_on_body_entered(body: Node):
  log.pp(body.name)

func on_respawn():
  if root.loadDefaultData:
    velocity = Vector2.ZERO
    speed = 50
    global_position = root.startPosition
