@icon("images/1.png")
extends EditorBlock
class_name BlockLightSwitch

func on_body_entered(body: Node) -> void:
  if body is Player:
    global.player.lightsOut = !global.player.lightsOut

func on_respawn() -> void:
  $collisionNode.position = Vector2.ZERO
