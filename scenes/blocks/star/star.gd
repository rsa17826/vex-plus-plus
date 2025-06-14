extends "res://scenes/blocks/editor.gd"

@export_group("STAR")

var collected = false

func on_ready() -> void:
  await global.wait()
  await global.wait()
  await global.wait()
  await global.wait()
  log.err("collected")
  if collected:
    await global.wait()
    __disable.call_deferred()

func on_respawn() -> void:
  $collisionNode.position = Vector2.ZERO
  if collected:
    __disable.call_deferred()
  
func on_body_entered(body: Node) -> void:
  if body == global.player:
    __disable.call_deferred()
    collected = true

func onSave() -> Array[String]:
  return ["collected"]