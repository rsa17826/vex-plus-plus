@icon("images/1.png")
extends EditorBlock
class_name BlockCheckpoint

@export var sprite: Node2D
const temp1 = preload("res://scenes/blocks/checkpoint/images/1.png")
const temp2 = preload("res://scenes/blocks/checkpoint/images/2.png")
const temp3 = preload("res://scenes/blocks/checkpoint/images/3.png")

var texture:
  get():
    return getTexture(sprite)
  set(val):
    setTexture(sprite, val)

func on_body_entered(body: Node) -> void:
  if body == global.player and (getTexture(sprite) == '1' or selectedOptions.multiUse):
    global.savePlayerLevelData()
    global.player.lastSpawnPoint = \
    (startPosition - global.player.get_parent().global_position) \
    + (Vector2(1.4725714286, -20.0802857143).rotated(deg_to_rad(startRotation_degrees)))
    # offset by 1/7*sprite position
    global.player.lightsOut = false
    setTexture(sprite, "2")
    global.checkpoints = global.checkpoints.filter(func(e: Variant) -> bool:
      return is_instance_valid(e))
    for checkpoint in global.checkpoints:
      if checkpoint == self: continue
      if getTexture(checkpoint.sprite) == '2':
        setTexture(checkpoint.sprite, '1' if checkpoint.selectedOptions.multiUse else '3')

func on_respawn() -> void:
  thingThatMoves.position = Vector2.ZERO
  
func on_ready() -> void:
  if not self in global.checkpoints:
    global.checkpoints.append(self )
  setTexture(sprite, "1")

func onSave() -> Array[String]:
  return ["texture"]

func generateBlockOpts():
  blockOptions.multiUse = {"type": global.PromptTypes.bool, "default": false}