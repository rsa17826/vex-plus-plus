extends CharacterBody2D
# @name same line return
# @regex :\s*return(\s*.{0,10})$
# @replace : return$1
# @flags gm
# @endregex

@export var root: EditorBlock

var vel := {
  "conveyer": Vector2.ZERO,
}
var velDecay := {
  "conveyer": .9
}

func on_physics_process(delta: float) -> void:
  if root.respawning: return
  if root._DISABLED: return
  if currentWatters:
    velocity.y -= max(95 * delta * (velocity.y / 8), 10)
  else:
    if is_on_floor():
      velocity.y =0
    velocity.y += global.player.GRAVITY * delta
  velocity.x *= .90 if is_on_floor() else .97
  var lastvel = velocity
  velocity += vel.conveyer
  move_and_slide()
  velocity -= vel.conveyer
  vel.conveyer *= velDecay.conveyer
  for i in get_slide_collision_count():
    var collision := get_slide_collision(i)
    var block := collision.get_collider()
    var normal := collision.get_normal()

    if normal == Vector2.UP \
    and lastvel.y > 700 \
    and block.root is BlockBomb \
    :
      block.root.explode()
    block = block.root
    if (block is BlockConveyerLeft or block is BlockConveyerRight) \
    and normal == Vector2.UP \
    and lastvel.y >= 0 \
    :
      if block is BlockConveyerRight:
        vel.conveyer.x = 400
      else:
        vel.conveyer.x = -400
        
func on_ready(first=false):
  vel.conveyer = Vector2.ZERO
  velocity = Vector2.ZERO
  global_position = root.startPosition

func on_respawn():
  vel.conveyer = Vector2.ZERO
  velocity = Vector2.ZERO
  global_position = root.startPosition

var currentWatters = []

func _on_area_2d_area_entered(area: Area2D) -> void:
  if area not in currentWatters:
    currentWatters.append(area)

func _on_area_2d_area_exited(area: Area2D) -> void:
  if area in currentWatters:
    currentWatters.erase(area)
