@icon("images/1.png")
extends EditorBlock
class_name Block10xSolarSpike

func on_respawn():
  # $Node2D.position = Vector2(0, 11-72.5)
  thingThatMoves.position = Vector2.ZERO

var spikeWasJustEnabled := 0

func on_physics_process(delta: float) -> void:
  if spikeWasJustEnabled > 0:
    spikeWasJustEnabled -= 1
  if global.player.lightsOut:
    __disable()
  else:
    if _DISABLED:
      spikeWasJustEnabled = 3
    __enable()

func getDeathMessage(message: String, dir: Vector2) -> String:
  log.pp(spikeWasJustEnabled)
  if spikeWasJustEnabled > 0:
    message += "was caught unaware by an invisible spike"
  else:
    match dir:
      Vector2.UP:
        message += "jumped into a spike"
      Vector2.DOWN:
        message += "jumped on a spike"
      Vector2.LEFT, Vector2.RIGHT:
        message += "walked into a spike"
      Vector2.ZERO:
        message += "got teleported into a spike"
  return message