extends CharacterBody2D
# @name same line return
# @regex :\s*return(\s*.{0,10})$
# @replace : return$1
# @flags gm
# @endregex

@export var root: EditorBlock

func on_physics_process(delta: float) -> void:
  if root.respawning: return
  if root._DISABLED: return
  if currentWatters:
    velocity.y -= max(95 * delta * (velocity.y / 8), 10)
  else:
    if not is_on_floor():
      velocity.y += global.player.GRAVITY * delta
  velocity.x *= .90 if is_on_floor() else .97
  var lastvel = velocity
  move_and_slide()
  for i in get_slide_collision_count():
    var collision := get_slide_collision(i)
    var block := collision.get_collider()

    var normal := collision.get_normal()
    if normal == Vector2.UP \
    and lastvel.y > 700 \
    and block.root is BlockBomb \
    :
      block.root.explode()
  
func on_ready(first=false):
  velocity = Vector2(0, 0)
  global_position = root.startPosition

func on_respawn():
  velocity = Vector2(0, 0)
  global_position = root.startPosition

var currentWatters = []

func _on_area_2d_area_entered(area: Area2D) -> void:
  if area not in currentWatters:
    currentWatters.append(area)

func _on_area_2d_area_exited(area: Area2D) -> void:
  if area in currentWatters:
    currentWatters.erase(area)
