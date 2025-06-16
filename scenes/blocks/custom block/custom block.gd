@icon("images/1.png")
extends EditorBlock
class_name BlockCustomBlock

func generateBlockOpts():
  blockOptions.where = {"type": global.PromptTypes.string, "default": ""}

var childBlocks = []

func on_ready() -> void:
  log.pp(global.path.abs(
    "res://custom blocks/" +
    selectedOptions.where
    + ".sds"
  ))
  if !selectedOptions.where: return
  var blockData = sds.loadDataFromFile(
    global.path.abs(
      "res://custom blocks/" +
      selectedOptions.where
      + ".sds"
    )
  )
  childBlocks = []
  for block in blockData:
    var node := global.createNewBlock(block)
    childBlocks.append(node)
    node.EDITOR_IGNORE = true
    node.global_position = node.startPosition + startPosition
    node.rotation_degrees = node.startRotation_degrees + startRotation_degrees
    node.scale = node.startScale + startScale
    add_child(node)

func on_process(delta: float):
  for node in childBlocks:
    node.global_position = node.startPosition + startPosition
