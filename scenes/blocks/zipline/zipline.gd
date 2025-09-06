@icon("images/1.png")
extends EditorBlock
class_name BlockZipline

var targetZipline: BlockZipline
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
  targetZipline = global.ziplines[global.ziplines.find_custom(func(e):
    return e.selectedOptions.id == selectedOptions.id
  )]
  queue_redraw()

func on_physics_process(delta: float) -> void:
  if !targetZipline or targetZipline == self: return
  # log.pp(colliding())
  ray.target_position = targetZipline.position - position
  ray.global_position = global_position + Vector2(0, -sizeInPx.y / 2)
  ray.scale = Vector2(1, 1) / scale
  # log.pp(Vector2(0, -defaultSizeInPx.y / 2), ray.position, position, global_position, ray.global_position)
  # log.pp(targetZipline.position - position)
  if ray.is_colliding():
    if global.player.ziplineCooldown > 0: return
    var loopCount = 0
    while ray.is_colliding() and loopCount < 200:
      ray.force_raycast_update()
      loopCount += 1
      ray.position -= global.player.applyRot(Vector2(0, 1))
    ray.position += global.player.applyRot(Vector2(0, loopCount * 1))
    global.player.position += global.player.applyRot(Vector2(0, loopCount / 10.0 - 2 ))
    log.err(loopCount)
    global.player.activeZipline = self
    global.player.targetZipline = targetZipline
    global.player.state = global.player.States.onZipline
  else:
    if global.player.activeZipline == self:
      global.player.activeZipline = null
      global.player.targetZipline = null
      global.player.state = global.player.States.falling

func direction(p1: Vector2, p2: Vector2, p3: Vector2) -> float:
  return (p3.y - p1.y) * (p2.x - p1.x) - (p3.x - p1.x) * (p2.y - p1.y)

func _draw() -> void:
  # log.pp(targetZipline, global.ziplines)
  if targetZipline and targetZipline != self:
    draw_line(
      Vector2.ZERO \
      + Vector2(0, -defaultSizeInPx.y / 2),

      to_local(targetZipline.startPosition) \
      + (Vector2(0, -targetZipline.defaultSizeInPx.y / 2) / scale * targetZipline.scale)

    , Color(1, 0.5, 0), -50)