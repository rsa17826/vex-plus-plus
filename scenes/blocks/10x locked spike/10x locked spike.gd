@icon("images/editorBar.png")
extends EditorBlock
class_name Block10xLockedSpike

func on_respawn():
  __enable()
  thingThatMoves.position = Vector2.ZERO

var unlocked := false

func on_body_entered(body: Node2D):
  if body is Player:
    unlock()
    if not unlocked:
      body.deathSources.append(self )

func unlock() -> void:
  if global.player.keys and not unlocked:
    unlocked = true
    var key: Node2D = global.player.keys.pop_front()
    key.root.__disable()
    __disable()
    for block: EditorBlock in attach_children:
      block.__disable()
    await global.wait()
    await global.wait()
    unlocked = false

func on_body_exited(body: Node2D):
  if body is Player:
    if self in body.deathSources:
      body.deathSources.erase(self )