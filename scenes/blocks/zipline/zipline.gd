@icon("images/1.png")
extends EditorBlock
class_name BlockZipline

var targetZipline: BlockZipline
var cd = 0
@export var ray: RayCast2D

func _init() -> void:
  if self not in global.ziplines:
    global.ziplines.append(self )

func generateBlockOpts():
  blockOptions.id = {
    "type": global.PromptTypes.int,
    "default": len(global.ziplines)
  }

func on_process(delta: float) -> void:
  log.pp(global.ziplines)
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
  if !targetZipline or targetZipline == self or global.player.state == global.player.States.sliding:
    ray.target_position = Vector2.ZERO
    ray.enabled = false
    return
  ray.enabled = true
  cd -= 1
  # log.pp(colliding())
  ray.target_position = targetZipline.position - position
  ray.global_position = global_position + Vector2(0, -sizeInPx.y / 2 + 10)
  ray.scale = Vector2(1, 1) / scale
  # log.pp(Vector2(0, -defaultSizeInPx.y / 2), ray.position, position, global_position, ray.global_position)
  # log.pp(targetZipline.position - position)
  if ray.is_colliding() or cd > 0:
    if global.player.ziplineCooldown > 0: return
    var diff = global.player.applyRot(ray.get_collision_point() - global.player.global_position).y
    log.pp(diff)
    # global.player.global_position.y = ray.get_collision_point().y
    global.player.global_position += global.player.applyRot(Vector2(0, diff + 6))

    # var loopCount = 0
    # ray.position += global.player.applyRot(Vector2(0, 10))
    # while ray.is_colliding() and loopCount < 1000:
    #   ray.force_raycast_update()
    #   loopCount += 1
    #   ray.position -= global.player.applyRot(Vector2(0, 1))
    # log.pp(loopCount)
    # global.player.global_position += global.player.applyRot(Vector2(0, clamp((loopCount - 10), 0, INF) / 7.0))
    # global.player.global_position += global.player.applyRot(Vector2(0, -20))
    # ray.position += global.player.applyRot(Vector2(0, loopCount - 10))
    if global.player.activeZipline != self and cd <= 0:
      cd = 4
    global.player.activeZipline = self
    global.player.targetZipline = targetZipline
    global.player.state = global.player.States.onZipline
  else:
    if global.player.activeZipline == self:
      global.player.remainingJumpCount -= 1
      global.player.activeZipline = null
      global.player.targetZipline = null
      global.player.state = global.player.States.falling

func _draw() -> void:
  # log.pp(targetZipline, global.ziplines)
  if targetZipline and targetZipline != self:
    draw_line(
      Vector2.ZERO \
      + Vector2(-5, -defaultSizeInPx.y / 2 + 65),

      to_local(targetZipline.startPosition) \
      + (Vector2(-5, -targetZipline.defaultSizeInPx.y / 2 + 65) / scale * targetZipline.scale)

    , Color(1, 0.5, 0), 10)