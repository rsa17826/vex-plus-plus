@icon("images/editorBar.png")
extends EditorBlock
class_name Block10xLockedSpike

func on_respawn() -> void:
  if loadDefaultData:
    __enable()
    unlocked = false

var unlocked := false

func on_body_entered(body: Node2D):
  if body is Player and not unlocked:
    unlock()
    if not unlocked:
      deathEnter(body)

func unlock() -> void:
  if global.player.keys and not unlocked:
    unlocked = true
    var key: Node2D = global.player.keys.pop_front()
    key.root.following = false
    key.root.used = true
    key.root.__disable.call_deferred()
    __disable.call_deferred()

func on_body_exited(body: Node2D):
  deathExit(body)

func onSave() -> Array[String]:
  return ["unlocked"]

func onAllDataLoaded() -> void:
  if unlocked:
    global.player.Alltryaddgroups.connect(func():
      __disable.call_deferred()
    , Object.CONNECT_ONE_SHOT)

func getDeathMessage(message: String, dir: Vector2) -> String:
  log.pp(dir)
  match dir:
    Vector2.UP:
      message += "jumped into a spike"
    Vector2.DOWN:
      message += "jumped on a spike"
    Vector2.LEFT, Vector2.RIGHT:
      message += "walked into a spike"
    Vector2.ZERO:
      message += "got teleported into a spike"
  return message