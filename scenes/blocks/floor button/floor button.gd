@icon("images/unpressed.png")
extends EditorBlock
class_name BlockFloorButton

var activeBlocks := []
@export var sprite: Sprite2D

func on_body_entered(body: Node) -> void:
  if body not in activeBlocks:
    activeBlocks.append(body)
  if activeBlocks:
    setTexture(sprite, "pressed")
    for block in global.buttonWalls:
      block.on_button_activated(selectedOptions.buttonId, self )
      
func on_respawn() -> void:
  thingThatMoves.position = Vector2.ZERO

func on_body_exited(body: Node) -> void:
  if body in activeBlocks:
    activeBlocks.erase(body)
  if not activeBlocks:
    setTexture(sprite, "unpressed")
    for block in global.buttonWalls:
      block.on_button_deactivated(selectedOptions.buttonId, self )

func generateBlockOpts():
  blockOptions.buttonId = {"type": global.PromptTypes.int, "default": 0}