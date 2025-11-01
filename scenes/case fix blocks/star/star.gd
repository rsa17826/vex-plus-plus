@icon("images/1.png")
extends EditorBlock
class_name BlockStar

var collected = false
@export var sprite: Sprite2D

func on_ready() -> void: pass

func onDataLoaded() -> void:
  if collected:
    __disable()

func generateBlockOpts():
  blockOptions.unCollect = {
    "type": 'BUTTON',
    "onChange": func():
      collected = false
      __enable()
  }
  blockOptions.starType = {
    "type": global.PromptTypes._enum,
    "values": [
      "yellow",
      "blue",
      "pink"
    ],
    "default": 0
  }

func on_respawn() -> void:
  $collisionNode.position = Vector2.ZERO
  setTexture(sprite, str(selectedOptions.starType + 1))
  if collected:
    __disable.call_deferred()

func on_body_entered(body: Node) -> void:
  if body is Player:
    __disable.call_deferred()
    collected = true
    global.savePlayerLevelData(true)

func __enable() -> void:
  # for when attached to things like locked box and solar
  if not collected:
    super()

func onSave() -> Array[String]:
  return ["collected"]