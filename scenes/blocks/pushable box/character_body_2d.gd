extends CharacterBody2D
# @name same line return
# @regex :\s*return(\s*.{0,10})$
# @replace : return$1
# @flags gm
# @endregex

@export var root: Editor

func on_physics_process(delta: float) -> void:
  if get_parent().respawning: return
  if currentWatters:
    velocity.y -= max(95 * delta * (velocity.y / 8), 10)
  else:
    if not is_on_floor():
      velocity.y += global.player.GRAVITY * delta
  velocity.x *= .90 if is_on_floor() else .97
  move_and_slide()
  
func on_ready(first=false):
  velocity = Vector2(0, 0)
  global_position = get_parent().startPosition

func on_respawn():
  velocity = Vector2(0, 0)
  global_position = get_parent().startPosition

var currentWatters = []

func _on_area_2d_area_entered(area: Area2D) -> void:
  if area not in currentWatters:
    currentWatters.append(area)

func _on_area_2d_area_exited(area: Area2D) -> void:
  if area in currentWatters:
    currentWatters.erase(area)
