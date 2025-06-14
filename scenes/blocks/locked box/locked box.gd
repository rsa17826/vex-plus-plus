extends "res://scenes/blocks/editor.gd"

@export_group("LOCKED_BOX")
# boxes can only be unlocked once per frame to prevent excessive key usage
var unlocked := false
func unlock() -> void:
  if len(global.player.keys) and not unlocked:
    unlocked = true
    log.pp(global.player.keys)
    var key: Node2D = global.player.keys.pop_front()
    key.root.__disable()
    __disable()
    await global.wait()
    unlocked = false

func on_respawn() -> void:
  __enable()
