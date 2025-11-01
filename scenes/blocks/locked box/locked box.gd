@icon("images/1.png")
extends EditorBlock
class_name BlockLockedBox

@export var mask: AnimatedSprite2D

var unlocked := false
func unlock() -> void:
  if global.player.keys and not unlocked:
    unlocked = true
    var key: Node2D = global.player.keys.pop_front()
    key.root.following = false
    key.root.used = true
    mask.play("unlock")
    key.root.__disable.call_deferred()
    mask.animation_finished.connect(d)
    __disable.call_deferred(true)
    for block: EditorBlock in attach_children:
      block.__disable.call_deferred()

func d():
  mask.visible = false

func on_respawn() -> void:
  if mask.animation_finished.is_connected(d):
    mask.animation_finished.disconnect(d)
  if loadDefaultData:
    __enable()
    unlocked = false
  if !unlocked:
    mask.frame = 0

func __enable():
  mask.visible = true
  mask.frame = 0
  super()
func __disable(fromSelf:=false) -> void:
  if fromSelf:
    mask.visible = true
  else:
    mask.frame = 0
  super()

func onSave() -> Array[String]:
  return ["unlocked"]

func onAllDataLoaded() -> void:
  if unlocked:
    global.player.Alltryaddgroups.connect(func():
      __disable.call_deferred()
      for block: EditorBlock in attach_children:
        block.__disable.call_deferred()
    , Object.CONNECT_ONE_SHOT)