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
  for block: EditorBlock in childBlocks:
    if is_instance_valid(block):
      block.queue_free.call_deferred()
  childBlocks = []
  for block in blockData:
    var node := global.createNewBlock(block)
    childBlocks.append(node)
    node.EDITOR_IGNORE = true
    node.startPosition = node.startPosition + startPosition
    node.startRotation_degrees = node.startRotation_degrees + startRotation_degrees
    node.startScale = node.startScale * startScale
    add_child(node)

# func on_physics_process(delta: float) -> void:
#   for node in childBlocks:
#     node.global_position = node.startPosition + startPosition
