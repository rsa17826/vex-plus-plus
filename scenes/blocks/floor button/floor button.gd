@icon("images/unpressed.png")
extends EditorBlock
class_name BlockFloorButton

@export var sprite: Sprite2D

var blocksCurrentlyPressingThisButton := []:
  get():
    blocksCurrentlyPressingThisButton = blocksCurrentlyPressingThisButton.filter(global.isAlive)
    return blocksCurrentlyPressingThisButton

func on_body_entered(body: Node) -> void:
  if !selectedOptions.signalOutputId: return
  if body not in blocksCurrentlyPressingThisButton:
    blocksCurrentlyPressingThisButton.append(body)
  if blocksCurrentlyPressingThisButton:
    setTexture(sprite, "pressed")
    global.sendSignal(selectedOptions.signalOutputId, self , true)

func on_ready():
  global.sendSignal(selectedOptions.signalOutputId, self , false)

func on_respawn() -> void:
  thingThatMoves.position = Vector2.ZERO

func on_body_exited(body: Node) -> void:
  if body in blocksCurrentlyPressingThisButton:
    blocksCurrentlyPressingThisButton.erase(body)
  if not blocksCurrentlyPressingThisButton:
    setTexture(sprite, "unpressed")
    global.sendSignal(selectedOptions.signalOutputId, self , false)

func generateBlockOpts():
  blockOptions.signalOutputId = {"type": global.PromptTypes.int, "default": 0}