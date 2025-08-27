@icon("images/1.png")
extends EditorBlock
class_name BlockLockedBox

# boxes can only be unlocked once per frame to prevent excessive key usage
var unlocked := false
func unlock() -> void:
  if global.player.keys and not unlocked:
    unlocked = true
    log.pp(global.player.keys)
    var key: Node2D = global.player.keys.pop_front()
    key.root.__disable()
    __disable()
    for block: EditorBlock in attach_children:
      block.__disable()
    await global.wait()
    unlocked = false

func on_respawn() -> void:
  __enable()
