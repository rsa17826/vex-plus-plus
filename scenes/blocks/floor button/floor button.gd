@icon("images/unpressed.png")
extends EditorBlock
class_name BlockFloorButton

var activeBlocks := []
@export var sprite: Sprite2D

func on_body_entered(body: Node) -> void:
  if !selectedOptions.buttonId: return
  if body not in activeBlocks:
    activeBlocks.append(body)
  if activeBlocks:
    setTexture(sprite, "pressed")
    if self not in global.activeBtns:
      global.activeBtns.append(self )
    if global.activeBtns:
      global.onButtonActivated.emit(selectedOptions.buttonId, self )
      
func on_respawn() -> void:
  thingThatMoves.position = Vector2.ZERO

func on_body_exited(body: Node) -> void:
  if !selectedOptions.buttonId: return
  if body in activeBlocks:
    activeBlocks.erase(body)
  if not activeBlocks:
    setTexture(sprite, "unpressed")
    if self in global.activeBtns:
      global.activeBtns.erase(self )
    if !global.activeBtns:
      global.onButtonDeactivated.emit(selectedOptions.buttonId, self )

func generateBlockOpts():
  blockOptions.buttonId = {"type": global.PromptTypes.int, "default": 0}