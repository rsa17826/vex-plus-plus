@icon("images/editorBar.png")
extends EditorBlock
class_name Block10xLockedSpike

func on_respawn() -> void:
  __enable()
  unlocked = false

var unlocked := false

func on_body_entered(body: Node2D):
  if body is Player and not unlocked:
    unlock()
    if not unlocked:
      if not self in body.deathSources:
        body.deathSources.append(self )

func unlock() -> void:
  if global.player.keys and not unlocked:
    unlocked = true
    var key: Node2D = global.player.keys.pop_front()
    key.root.__disable()
    key.root.following = false
    key.root.used = true
    __disable.call_deferred()
    await global.wait()

func on_body_exited(body: Node2D):
  if body is Player:
    if self in body.deathSources:
      body.deathSources.erase(self )

func onSave() -> Array[String]:
  return ["unlocked"]

func onAllDataLoaded() -> void:
  if unlocked:
    global.player.Alltryaddgroups.connect(func():
      __disable.call_deferred()
    , Object.CONNECT_ONE_SHOT)