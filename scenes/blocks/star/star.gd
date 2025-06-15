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
  if body == global.player:
    __disable.call_deferred()
    collected = true
    global.savePlayerLevelData()

func onSave() -> Array[String]:
  return ["collected"]