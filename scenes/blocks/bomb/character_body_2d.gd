extends CharacterBody2D
# @name same line return
# @regex :\s*return(\s*.{0,10})$
# @replace : return$1
# @flags gm
# @endregex

@export var root: EditorBlock

var collsiionOn_top = []
var collsiionOn_bottom = []
var collsiionOn_left = []
var collsiionOn_right = []

func on_physics_process(delta: float) -> void:
  if root.respawning: return
  if root.exploded: return
  if currentWatters:
    velocity.y -= max(95 * delta * (velocity.y / 8), 10)
  else:
    if not is_on_floor():
      velocity.y += global.player.GRAVITY * delta
  velocity.x *= .90 if is_on_floor() else .97
  var shouldExplode = velocity.y > 700
  # log.pp(velocity.y)
  move_and_slide()
  if is_on_floor() and shouldExplode:
    root.explode()
  if (len(collsiionOn_top) and len(collsiionOn_bottom)) \
  or (len(collsiionOn_left) and len(collsiionOn_right)):
    log.pp(collsiionOn_top, collsiionOn_bottom, collsiionOn_left, collsiionOn_right)
    root.explode()

func on_ready(first=false):
  velocity = Vector2(0, 0)
  global_position = root.startPosition

func on_respawn():
  velocity = Vector2(0, 0)
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