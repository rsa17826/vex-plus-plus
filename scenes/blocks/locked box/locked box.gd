@icon("images/1.png")
extends EditorBlock
class_name BlockLockedBox

# boxes can only be justUnlocked once per frame to prevent excessive key usage
var justUnlocked := false
var unlocked := false
func unlock() -> void:
  if global.player.keys and not justUnlocked:
    unlocked = true
    justUnlocked = true
    var key: Node2D = global.player.keys.pop_front()
    key.root.__disable()
    key.root.following = false
    key.root.used = true
    __disable()
    for block: EditorBlock in attach_children:
      block.__disable()
    await global.wait()
    justUnlocked = false

func on_respawn() -> void:
  __enable()
  unlocked = false

func onSave() -> Array[String]:
  return ["unlocked"]

func onAllDataLoaded() -> void:
  if unlocked:
    __hideAll.call_deferred()
    global.player.Alltryaddgroups.connect(func():
      __disable()
      for block: EditorBlock in attach_children:
        block.__disable.call_deferred()
    , Object.CONNECT_ONE_SHOT)