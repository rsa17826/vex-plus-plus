@icon("images/1.png")
extends EditorBlock
class_name BlockAreaTrigger

var thingsInside: Array[EditorBlock] = []

func on_body_entered(body: Node2D) -> void:
  if body.root not in thingsInside:
    thingsInside.append(body.root)
  global.sendSignal(selectedOptions.signalOutputId, self , !!thingsInside)

func on_body_exited(body: Node2D) -> void:
  if body.root in thingsInside:
    thingsInside.erase(body.root)
  global.sendSignal(selectedOptions.signalOutputId, self , !!thingsInside)

func on_respawn():
  thingsInside.assign([])
  global.sendSignal(selectedOptions.signalOutputId, self , false)

func generateBlockOpts():
  blockOptions.signalOutputId = {"type": global.PromptTypes.int, "default": 0}
