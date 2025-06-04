extends "res://scenes/blocks/editor.gd"

@export_group("KEY")
var following := false
func _on_body_enteredKEY(body: Node) -> void:
  if body == global.player and not following and not self in global.player.keys:
    global.player.keys.append(self)
    log.pp("key added", self)
    following = true

func on_respawn() -> void:
  following = false
  $collisionNode.position = Vector2.ZERO

func _processKEY(delta: float) -> void:
  if !following: return
  global_position = global.player.global_position