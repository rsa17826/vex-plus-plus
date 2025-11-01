extends CharacterBody2D
const SMALL = .00001

@export var root: EditorBlock

var vel := {
  "conveyor": Vector2.ZERO,
  "default": Vector2.ZERO,
  "wind": Vector2.ZERO,
}
var velDecay := {
  "conveyor": .9,
  "wind": .7,
}
func _ready() -> void:
  global.gravChanged.connect(func(lastUpDir, newUpDir):
    for v in vel:
      vel[v]=vel[v].rotated(angle_difference(lastUpDir.angle(), newUpDir.angle()))
  )

func on_physics_process(delta: float) -> void:
  if root.respawning: return
  if root._DISABLED: return
  if !delta: return
  up_direction = global.player.up_direction
  if currentWatters:
    vel.default.y -= max(95 * delta * (vel.default.y / 8), 10)
  else:
    if is_on_floor():
      vel.default.y = 0
    if is_on_ceiling() and vel.default.y < 0:
      vel.default.y = 0
    vel.default.y += Player.GRAVITY * delta
  vel.default.x *= .90 if is_on_floor() else .97
  var lastvel = vel.default
  # vel.default += vel.conveyor
  velocity = global.player.applyRot(vel.default + vel.conveyor + vel.wind)
  move_and_slide()
  # vel.default -= vel.conveyor
  vel.conveyor *= (velDecay.conveyor)
  vel.wind *= velDecay.wind
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
    handleCollision(block, normal, collision.get_depth(), collision.get_position())

func handleCollision(b: Node2D, normal: Vector2, depth: float, position: Vector2) -> void:
  var block: EditorBlock = b.root
  var blockSide = global.player.calcHitDir(normal.rotated(global.player.defaultAngle).rotated(-deg_to_rad(block.startRotation_degrees)))

  var v = normal.rotated(-global.player.defaultAngle)
  var vv = Vector2.UP
  var hitTop = v.distance_to(vv) < 0.77
  var hitBottom = v.distance_to(vv.rotated(deg_to_rad(180))) < 0.77
  var hitLeft = v.distance_to(vv.rotated(deg_to_rad(-90))) < 0.77
  var hitRight = v.distance_to(vv.rotated(deg_to_rad(90))) < 0.77
  var single = len([hitTop, hitBottom, hitLeft, hitRight].filter(func(e): return e)) == 1
  var playerSide = {"top": hitBottom, "bottom": hitTop, "left": hitRight, "right": hitLeft, "single": single}

  if (block is BlockPushableBox or block is BlockBomb) \
  and is_on_floor() \
  and (playerSide.left or playerSide.right) \
  :
    block.thingThatMoves.vel.default -= (normal.rotated(-global.player.defaultAngle) * depth * 200)
  # if block is BlockConveyor:
  #   if rotatedNormal != UP:
    # log.err([rotatedNormal, UP], global.player.defaultAngle, up_direction, [normal, Vector2.UP])

  if (block is BlockConveyor) \
  # and playerSide.bottom \
  and vel.default.y >= -SMALL \
  :
    var speed = 400
    # log.pp(normal == Vector2(-1, 0), blockSide)
    # log.pp(playerSide, blockSide)
    if not blockSide.single: return
    if playerSide.bottom and blockSide.top:
      vel.conveyor.x = - speed
    elif playerSide.bottom and blockSide.bottom:
      vel.conveyor.x = speed
    elif playerSide.bottom and blockSide.left: pass
    elif playerSide.bottom and blockSide.right: pass
    elif playerSide.left and blockSide.left: pass
    elif playerSide.right and blockSide.right: pass
    elif playerSide.right and blockSide.left: pass
    elif playerSide.left and blockSide.right: pass
    elif playerSide.left and blockSide.top:
      vel.conveyor.y = - speed
    elif playerSide.left and blockSide.bottom:
      vel.conveyor.y = speed
    elif playerSide.right and blockSide.top:
      vel.conveyor.y = speed
    elif playerSide.right and blockSide.bottom:
      vel.conveyor.y = - speed
    elif playerSide.top and blockSide.top: pass
    elif playerSide.top and blockSide.bottom: pass
    else:
      log.err("invalid collision direction!!!", normal, playerSide, blockSide)

func on_respawn():
  if root.loadDefaultData:
    vel.conveyor = Vector2.ZERO
    vel.default = Vector2.ZERO
    velocity = Vector2.ZERO
    global_position = root.startPosition

var currentWatters = []

func _on_area_2d_area_entered(area: Area2D) -> void:
  if area not in currentWatters:
    currentWatters.append(area)

func _on_area_2d_area_exited(area: Area2D) -> void:
  if area in currentWatters:
    currentWatters.erase(area)
