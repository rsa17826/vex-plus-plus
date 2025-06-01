extends HFlowContainer
var keybinds
var dictkey: String
@export var keybindNode: Control
@export var runActionNode: Control
@export var actionTextNode: Control
func _ready() -> void:
  await global.wait(1000)
  actionTextNode.text = dictkey