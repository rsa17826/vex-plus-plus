extends CharacterBody2D

@export var root: EditorBlock
@export var sprite: Sprite2D

var dir = 1
func on_respawn():
  if root.loadDefaultData:
    dir = 1
    velocity = Vector2.ZERO

const speed = 120

func on_physics_process(delta: float) -> void:
  if root.respawning: return
  if root._DISABLED: return
  sprite.flip_h = dir == -1
  if not delta: return
  velocity.x = dir * speed
  velocity.y += Player.GRAVITY * delta / 2.5
  move_and_slide()
  if global.player.state == Player.States.dead:
    log.pp('spike', delta, velocity)
  for i in get_slide_collision_count():
    var collision := get_slide_collision(i)
    var block := collision.get_collider()
    var normal := collision.get_normal()
    var depth := collision.get_depth()
    handleCollision(block, normal, depth, collision.get_position())

func handleCollision(b: Node2D, normal: Vector2, depth: float, position: Vector2) -> void:
  var block: EditorBlock = b.root

  var v = normal.rotated(-global.player.defaultAngle)
  var vv = Vector2.UP
  var hitTop = v.distance_to(vv) < 0.77
  var hitBottom = v.distance_to(vv.rotated(deg_to_rad(180))) < 0.77
  var hitLeft = v.distance_to(vv.rotated(deg_to_rad(-90))) < 0.77
  var hitRight = v.distance_to(vv.rotated(deg_to_rad(90))) < 0.77
  var single = len([hitTop, hitBottom, hitLeft, hitRight].filter(func(e): return e)) == 1
  var playerSide = {"top": hitBottom, "bottom": hitTop, "left": hitRight, "right": hitLeft, "single": single}
  if block.respawning: return
  if playerSide.left:
    dir = 1
  if playerSide.right:
    dir = -1
