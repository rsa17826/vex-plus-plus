@icon("images/1.png")
extends EditorBlock
class_name BlockZipline

var targetZipline: BlockZipline
## per player cooldown
var cds: Dictionary[Player, int] = {}
@export var ray: RayCast2D

func _init() -> void:
  if self not in global.ziplines:
    global.ziplines.append(self)

func generateBlockOpts():
  blockOptions.id = {
    "type": global.PromptTypes.int,
    "default": len(global.ziplines)
  }

func on_process(delta: float) -> void:
  var idx = global.ziplines.find_custom(func(e):
    return \
      e.selectedOptions.id == selectedOptions.id \
      and e != self \
      and !(e.startPosition.y > startPosition.y)
    )
  if idx == -1:
    targetZipline = null
  else:
    targetZipline = global.ziplines[idx]
  queue_redraw()

func on_physics_process(delta: float) -> void:
  if !targetZipline or targetZipline == self:
    ray.target_position = Vector2.ZERO
    ray.enabled = false
    return
  ray.enabled = true
  ray.target_position = targetZipline.position - position
  ray.global_position = global_position + Vector2(0, -sizeInPx.y / 2 + 10)
  ray.scale = Vector2(1, 1) / scale
  for p: Player in global.players:
    processPlayer(p)

func processPlayer(p: Player) -> void:
  if p.state == Player.States.sliding:
    if p.activeZipline == self:
      releasePlayer(p)
    return
  cds[p] = cds.get(p, 0) - 1
  # the ray is shared, so only let it see this player
  ray.clear_exceptions()
  for other: Player in global.players:
    if other == p: continue
    ray.add_exception(other.get_node("ziplineDetector"))
    ray.add_exception(other.get_node("ziplineDetectorForActiveZipline"))
  if p.activeZipline == self:
    ray.collision_mask = 131072 + 262144
  else:
    ray.collision_mask = 131072
  ray.force_raycast_update()
  if p.state != Player.States.dead and (ray.is_colliding() or cds[p] > 0):
    if p.ziplineCooldown > 0: return
    var diff = p.applyRot(ray.get_collision_point() - p.global_position).y
    if abs(diff) > 100: return
    p.global_position += p.applyRot(Vector2(0, diff + 6))
    if p.activeZipline != self and cds[p] <= 0:
      cds[p] = 4
    p.activeZipline = self
    p.targetZipline = targetZipline
    p.state = Player.States.onZipline
  else:
    if p.activeZipline == self:
      releasePlayer(p)

func releasePlayer(p: Player) -> void:
  p.remainingJumpCount -= 1
  p.activeZipline = null
  p.targetZipline = null
  p.state = Player.States.falling

func _draw() -> void:
  # log.pp(targetZipline, global.ziplines)
  if targetZipline and targetZipline != self:
    draw_line(
      Vector2.ZERO \
      + Vector2(-5, -defaultSizeInPx.y / 2 + 65),

      to_local(targetZipline.startPosition) \
      + (Vector2(-5, -targetZipline.defaultSizeInPx.y / 2 + 65) / scale * targetZipline.scale)

    , Color(1, 0.5, 0), 10)
