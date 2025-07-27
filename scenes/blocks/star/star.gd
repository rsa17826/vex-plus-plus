@icon("images/1.png")
extends EditorBlock
class_name BlockStar

var collected = false

func on_ready() -> void:
  pass

func onDataLoaded() -> void:
  if collected:
    __disable()

func on_respawn() -> void:
  $collisionNode.position = Vector2.ZERO
  if collected:
    __disable.call_deferred()

func on_body_entered(body: Node) -> void:
  if body is Player:
    __disable.call_deferred()
    collected = true
    global.savePlayerLevelData()

func __enable() -> void:
  # for when attached to things like locked box and solar
  if not collected:
    super ()

func onSave() -> Array[String]:
  return ["collected"]