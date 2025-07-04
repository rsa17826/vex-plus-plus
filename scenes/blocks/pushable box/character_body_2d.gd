extends CharacterBody2D
# @name same line return
# @regex :\s*return(\s*.{0,10})$
# @replace : return$1
# @flags gm
# @endregex

@export var root: EditorBlock

var vel := {
  "conveyer": Vector2.ZERO,
  "default": Vector2.ZERO,
}
var velDecay := {
  "conveyer": .9
}
func _ready() -> void:
  global.gravChanged.connect(func(lastUpDir, newUpDir):
    for v in vel:
      vel[v]=vel[v].rotated(angle_difference(lastUpDir.angle(), newUpDir.angle()))
  )
  
func on_physics_process(delta: float) -> void:
  if root.respawning: return
  if root._DISABLED: return
  up_direction = global.player.up_direction
  if currentWatters:
    vel.default.y -= max(95 * delta * (vel.default.y / 8), 10)
  else:
    if is_on_floor():
      vel.default.y = 0
    if is_on_ceiling() and vel.default.y < 0:
      vel.default.y = 0
    vel.default.y += global.player.GRAVITY * delta
  vel.default.x *= .90 if is_on_floor() else .97
  var lastvel = vel.default
  # vel.default += vel.conveyer
  velocity = global.player.applyRot(vel.default + vel.conveyer)
  move_and_slide()
  # vel.default -= vel.conveyer
  vel.conveyer *= (velDecay.conveyer)
  for i in get_slide_collision_count():
    var collision := get_slide_collision(i)
    var block := collision.get_collider()
    var normal := collision.get_normal()
    # var rotatedNormal = global.player.applyRot(normal)
    var hitTop = normal.distance_to(global.player.applyRot(Vector2.UP)) < 0.7
    if hitTop \
    and lastvel.y > 700 \
    and block.root is BlockBomb \
    :
      block.root.explode()
    block = block.root
    if (block is BlockConveyer) \
    and hitTop \
    and lastvel.y >= 0 \
    :
      if block is BlockConveyer:
        vel.conveyer.x = 400
      else:
        vel.conveyer.x = -400
        
func on_ready(first=false):
  vel.conveyer = Vector2.ZERO
  vel.default = Vector2.ZERO
  global_position = root.startPosition

func on_respawn():
  vel.conveyer = Vector2.ZERO
  vel.default = Vector2.ZERO
  global_position = root.startPosition

var currentWatters = []

func _on_area_2d_area_entered(area: Area2D) -> void:
  if area not in currentWatters:
    currentWatters.append(area)

func _on_area_2d_area_exited(area: Area2D) -> void:
  if area in currentWatters:
    currentWatters.erase(area)
