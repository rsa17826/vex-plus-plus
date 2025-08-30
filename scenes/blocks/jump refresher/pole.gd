@icon("images/1.png")
extends EditorBlock
class_name BlockJumpRefresher

@export var sprite: Sprite2D

func generateBlockOpts():
  blockOptions.contactOption = {
    "default": 0,
    "values": [
      "reset to max",
      "add one"
    ],
    "type": global.PromptTypes._enum
  }
func on_respawn():
  match selectedOptions.contactOption:
    0: setTexture(sprite, "1")
    1: setTexture(sprite, "2")

func on_body_entered(body: Node) -> void:
  if body is Player:
    match selectedOptions.contactOption:
      0: body.remainingJumpCount = body.MAX_JUMP_COUNT
      1: body.remainingJumpCount += 1