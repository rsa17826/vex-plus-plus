extends CharacterBody2D
# @name same line return
# @regex :\s*return(\s*.{0,10})$
# @replace : return$1
# @flags gm
# @endregex

var speed = 50
@export var rootNode: Node
func _physics_process(delta: float) -> void:
  if rootNode.respawning: return
  velocity.y += speed
  velocity.y *= .95
  if is_on_ceiling() or global_position.y < rootNode.startPosition.y:
    speed = 50
  move_and_slide()
  %CharacterBody2D.global_position = global_position
  if is_on_floor():
    speed = -50
func on_on_body_entered(body: Node):
  log.pp(body.name)
func on_ready(first=false):
  velocity = Vector2(0, 0)
  global_position = rootNode.startPosition

func on_respawn():
  velocity = Vector2(0, 0)
  global_position = rootNode.startPosition
