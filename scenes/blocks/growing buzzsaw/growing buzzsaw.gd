@icon("images/1.png")
extends EditorBlock
class_name BlockGrowingBuzsaw

@export var nodeToScale: Node2D

func on_respawn():
  $collisionNode.position = Vector2.ZERO

func on_physics_process(delta):
  if _DISABLED: return
  var s = ((sin(global.tick * .8) * 1.04) + 1.98)
  # log.pp(s, clamp(s, 1, 3))
  s = clamp(s, 1, 3)
  nodeToScale.scale = Vector2(s, s)

func getDeathMessage(message: String, dir: Vector2) -> String:
  match dir:
    Vector2.UP:
      message += "jumped into a growing buzzsaw"
    Vector2.DOWN:
      message += "fell onto a growing buzzsaw"
    Vector2.LEFT, Vector2.RIGHT:
      message += "walkedinto a growing buzzsaw"
    Vector2.ZERO:
      message += "let a buzzsaw grow into them"
  return message