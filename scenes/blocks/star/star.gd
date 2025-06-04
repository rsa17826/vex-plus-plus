extends "res://scenes/blocks/editor.gd"

@export_group("STAR")
func on_ready() -> void:
  # log.pp(global.currentLevel().foundStar, global.currentLevel())
  if global.currentLevel().foundStar:
    await global.wait()
    __disable.call_deferred()

func on_body_entered(body: Node) -> void:
  if body == global.player:
    __disable.call_deferred()
    global.starFound()