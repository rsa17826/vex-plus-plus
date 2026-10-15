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
## players that have already used this checkpoint
var takenBy: Array[Player] = []
## players whose current spawnpoint is this checkpoint
var activeFor: Array[Player] = []

func on_body_entered(body: Node) -> void:
  if ignorePlayerEntering and not global.useropts.__allowCheckpointReentryOnDeath:
    ignorePlayerEntering = false
    return
  if not body is Player: return
  var available: bool = selectedOptions.multiUse \
    or (body not in takenBy and (getTexture(sprite) == '1' or takenBy))
  if not available: return
  global.savePlayerLevelData()
  body.lastSpawnPoint = \
  (startPosition - body.root.global_position) \
  + (Vector2(1.4725714286, -20.0802857143).rotated(deg_to_rad(startRotation_degrees)))
  # offset by 1/7*sprite position
  global.lightsOut = false
  if body not in takenBy:
    takenBy.append(body)
  if body not in activeFor:
    activeFor.append(body)
  setTexture(sprite, "2")
  for checkpoint: BlockCheckpoint in global.checkpoints:
    if checkpoint == self: continue
    checkpoint.activeFor.erase(body)
    if not checkpoint.activeFor and getTexture(checkpoint.sprite) == '2':
      setTexture(checkpoint.sprite, '1' if checkpoint.selectedOptions.multiUse else '3')

func on_respawn() -> void:
  thingThatMoves.position = Vector2.ZERO

func on_ready() -> void:
  if not self in global.checkpoints:
    global.checkpoints.append(self)
  setTexture(sprite, "1")
  takenBy = []
  activeFor = []
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
