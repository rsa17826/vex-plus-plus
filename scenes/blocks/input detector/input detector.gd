@icon("images/1.png")
extends EditorBlock
class_name BlockInputDetector

@export var sprite: Sprite2D

var actions = ["jump", "down", "left", "right"]

func generateBlockOpts():
  blockOptions.action = {"type": global.PromptTypes._enum, "default": 0, 'values': actions}
  blockOptions.signalOutputId = {"type": global.PromptTypes.int, "default": 0}

func on_respawn():
  global.sendSignal(selectedOptions.signalOutputId, self , false)
  match selectedOptions.action:
    0: startRotation_degrees = 0
    1: startRotation_degrees = 180
    2: startRotation_degrees = -90
    3: startRotation_degrees = 90
  rotation_degrees = startRotation_degrees

func _input(event):
  if Input.is_action_pressed(actions[selectedOptions.action]):
    global.sendSignal(selectedOptions.signalOutputId, self , true)
    # setTexture(sprite, "1")
  else:
    global.sendSignal(selectedOptions.signalOutputId, self , false)
    # setTexture(sprite, "2")