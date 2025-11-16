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
      deathEnter(body)
    # log.pp(Vector2.UP.rotated(body.velocity.angle()), Vector2.UP.rotated(rotation))

func on_body_exited(body: Node2D):
  deathExit(body)


func getDeathMessage(message: String, dir: Vector2) -> String:
  match dir:
    Vector2.UP:
      message += "jumped into a spike"
    Vector2.DOWN:
      message += "got popped on a spike"
    Vector2.LEFT, Vector2.RIGHT:
      message += "walked right into a spike"
    Vector2.ZERO:
      message += "got teleported into a spike"
  return message