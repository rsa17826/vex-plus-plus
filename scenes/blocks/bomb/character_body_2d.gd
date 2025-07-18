extends CharacterBody2D

@export var root: EditorBlock

var collsiionOn_top = []
var collsiionOn_bottom = []
var collsiionOn_left = []
var collsiionOn_right = []
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
  if root.exploded: return
  up_direction = global.player.up_direction
  if currentWatters:
    vel.default.y -= max(95 * delta * (vel.default.y / 8), 10)
  else:
    if is_on_floor():
      vel.default.y = 0
    vel.default.y += global.player.GRAVITY * delta
  vel.default.x *= .90 if is_on_floor() else .97
  var lastvel = vel.default
  velocity = global.player.applyRot(vel.default + vel.conveyer)
  move_and_slide()
  vel.conveyer *= velDecay.conveyer
  if is_on_floor() and lastvel.y > 700:
    root.explode()
  if (len(collsiionOn_top) and len(collsiionOn_bottom)) \
  or (len(collsiionOn_left) and len(collsiionOn_right)):
    log.pp(collsiionOn_top, collsiionOn_bottom, collsiionOn_left, collsiionOn_right)
    root.explode()
  for i in get_slide_collision_count():
    var collision := get_slide_collision(i)
    var block := collision.get_collider()
    var normal := collision.get_normal()
    var rotatedNormal = global.player.applyRot(normal)
    block = block.root
    if (block is BlockConveyer) \
    and rotatedNormal == global.player.applyRot(Vector2.UP) \
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
  collsiionOn_top = []
  collsiionOn_bottom = []
  collsiionOn_left = []
  collsiionOn_right = []
  global_position = root.startPosition

var currentWatters = []

func _on_area_2d_area_entered(area: Area2D) -> void:
  if area not in currentWatters:
    currentWatters.append(area)

func _on_area_2d_area_exited(area: Area2D) -> void:
  if area in currentWatters:
    currentWatters.erase(area)

func _on_bottom_body_entered(body: Node2D) -> void:
  if body == self: return
  if body not in collsiionOn_bottom:
    collsiionOn_bottom.append(body)
func _on_bottom_body_exited(body: Node2D) -> void:
  if body == self: return
  if body in collsiionOn_bottom:
    collsiionOn_bottom.erase(body)

func _on_top_body_entered(body: Node2D) -> void:
  if body == self: return
  if body not in collsiionOn_bottom:
    collsiionOn_top.append(body)
func _on_top_body_exited(body: Node2D) -> void:
  if body == self: return
  if body in collsiionOn_top:
    collsiionOn_top.erase(body)

func _on_right_body_entered(body: Node2D) -> void:
  if body == self: return
  if body not in collsiionOn_right:
    collsiionOn_right.append(body)
func _on_right_body_exited(body: Node2D) -> void:
  if body == self: return
  if body in collsiionOn_right:
    collsiionOn_right.erase(body)

func _on_left_body_entered(body: Node2D) -> void:
  if body == self: return
  if body not in collsiionOn_left:
    collsiionOn_left.append(body)
func _on_left_body_exited(body: Node2D) -> void:
  if body == self: return
  if body in collsiionOn_left:
    collsiionOn_left.erase(body)