@icon("images/editorBar.png")
extends EditorBlock
class_name Block10xOnewaySpike

func on_respawn():
  # $Node2D.position = Vector2(0, 11-72.5)
  thingThatMoves.position = Vector2.ZERO

func on_body_entered(body: Node2D):
  if body is Player:
    var wantAngle = global.clearLow(Vector2.UP.rotated(rotation))
    var curAngle = body.velTotal.sign()
    log.pp(
      "oneway spikes entered:",
      body.velocity,
      body.velTotal,
      wantAngle,
      curAngle,
      rad_to_deg(angle_difference(curAngle.angle(), wantAngle.angle())),
      wantAngle.distance_to(curAngle)
    )
    if wantAngle.distance_to(curAngle) > 1.65:
      body.deathSources.append(self)
    # log.pp(Vector2.UP.rotated(body.velocity.angle()), Vector2.UP.rotated(rotation))

func on_body_exited(body: Node2D):
  if body is Player:
    if self in body.deathSources:
      body.deathSources.erase(self)