@icon("images/1.png")
extends EditorBlock
class_name BlockLockedBox

var unlocked := false
func unlock() -> void:
  if global.player.keys and not unlocked:
    unlocked = true
    var key: Node2D = global.player.keys.pop_front()
    key.root.__disable()
    key.root.following = false
    key.root.used = true
    __disable()
    for block: EditorBlock in attach_children:
      block.__disable()
    await global.wait()

func on_respawn() -> void:
  if loadDefaultData:
    __enable()
    unlocked = false

func onSave() -> Array[String]:
  return ["unlocked"]

func onAllDataLoaded() -> void:
  if unlocked:
    global.player.Alltryaddgroups.connect(func():
      __disable.call_deferred()
      for block: EditorBlock in attach_children:
        block.__disable.call_deferred()
    , Object.CONNECT_ONE_SHOT)