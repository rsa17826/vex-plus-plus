@icon("images/1.png")
extends EditorBlock
class_name BlockLightSwitch

func on_body_entered(body: Node) -> void:
  if body == global.player:
    global.player.lightsOut = true

func on_respawn() -> void:
  $collisionNode.position = Vector2.ZERO
