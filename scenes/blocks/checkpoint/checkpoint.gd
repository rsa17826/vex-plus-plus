@icon("images/1.png")
extends EditorBlock
class_name BlockCheckpoint

@export var sprite: Node2D

var texture:
  get():
    return getTexture(sprite)
  set(val):
    setTexture(sprite, val)

var ignorePlayerEntering := false

func on_body_entered(body: Node) -> void:
  if ignorePlayerEntering and not global.useropts.__allowCheckpointReentryOnDeath:
    ignorePlayerEntering = false
    return
  if body is Player and (getTexture(sprite) == '1' or selectedOptions.multiUse):
    global.savePlayerLevelData()
    global.player.lastSpawnPoint = \
    (startPosition - global.player.root.global_position) \
    + (Vector2(1.4725714286, -20.0802857143).rotated(deg_to_rad(startRotation_degrees)))
    # offset by 1/7*sprite position
    global.player.lightsOut = false
    setTexture(sprite, "2")
    for checkpoint in global.checkpoints:
      if checkpoint == self: continue
      if getTexture(checkpoint.sprite) == '2':
        setTexture(checkpoint.sprite, '1' if checkpoint.selectedOptions.multiUse else '3')

func on_respawn() -> void:
  thingThatMoves.position = Vector2.ZERO

func on_ready() -> void:
  if not self in global.checkpoints:
    global.checkpoints.append(self)
  setTexture(sprite, "1")
  ignorePlayerEntering = false

func onSave() -> Array[String]:
  return ["texture"]

func onDataLoaded() -> void:
  if getTexture(sprite) == '2' and selectedOptions.multiUse:
    ignorePlayerEntering = true
  else:
    ignorePlayerEntering = false

func generateBlockOpts():
  blockOptions.multiUse = {"type": global.PromptTypes.bool, "default": false}