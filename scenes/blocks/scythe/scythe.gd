@icon("images/1.png")
extends EditorBlock
class_name BlockScythe

@export var nodeToSpin: Node2D
func on_physics_process(delta: float) -> void:
  spin(-300, nodeToSpin)

func on_respawn() -> void:
  $collisionNode.position = Vector2.ZERO
  nodeToSpin.rotation = 0

func getDeathMessage(message: String, dir: Vector2) -> String:
  match dir:
    Vector2.UP:
      message += "jumped into a scythe"
    Vector2.DOWN:
      message += "fell onto a scythe"
    Vector2.LEFT, Vector2.RIGHT:
      message += "walked into a scythe"
    Vector2.ZERO:
      message += "stood in the path of a scythe"
  return message