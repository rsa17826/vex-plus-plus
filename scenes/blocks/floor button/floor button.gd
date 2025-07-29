@icon("images/unpressed.png")
extends EditorBlock
class_name BlockFloorButton

@export var sprite: Sprite2D

var blocksCurrentlyPressingThisButton := []:
  get():
    blocksCurrentlyPressingThisButton = blocksCurrentlyPressingThisButton.filter(global.isAlive)
    return blocksCurrentlyPressingThisButton

func on_body_entered(body: Node) -> void:
  # log.pp("on_body_", body in blocksCurrentlyPressingThisButton, body is Player, blocksCurrentlyPressingThisButton)
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
  for body in blocksCurrentlyPressingThisButton:
    on_body_exited(body)
  await global.wait(100)
  var overlaps = ($collisionNode as Area2D).get_overlapping_bodies() + ($collisionNode as Area2D).get_overlapping_areas()
  log.pp("respawn", overlaps, blocksCurrentlyPressingThisButton)
  for body in blocksCurrentlyPressingThisButton:
    on_body_exited(body)
  blocksCurrentlyPressingThisButton = []
  for body in overlaps:
    on_body_entered(body)
  thingThatMoves.position = Vector2.ZERO

func on_body_exited(body: Node) -> void:
  # log.pp("on_body_exited", body in blocksCurrentlyPressingThisButton, body is Player, blocksCurrentlyPressingThisButton)
  if body in blocksCurrentlyPressingThisButton:
    blocksCurrentlyPressingThisButton.erase(body)
  if not blocksCurrentlyPressingThisButton:
    setTexture(sprite, "unpressed")
    global.sendSignal(selectedOptions.signalOutputId, self , false)

func generateBlockOpts():
  blockOptions.signalOutputId = {"type": global.PromptTypes.int, "default": 0}