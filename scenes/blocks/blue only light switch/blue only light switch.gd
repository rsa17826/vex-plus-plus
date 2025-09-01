@icon("images/1.png")
extends EditorBlock
class_name BlockBlueOnlyLightSwitch

func on_body_entered(body: Node) -> void:
  if \
    body is Player \
    or body is BlockPushableBox \
    or body is BlockBomb \
  :
    global.player.lightsOut = false

func on_respawn() -> void:
  $collisionNode.position = Vector2.ZERO
