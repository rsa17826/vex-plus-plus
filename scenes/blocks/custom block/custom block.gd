@icon("images/1.png")
extends EditorBlock
class_name BlockCustomBlock

func generateBlockOpts():
  blockOptions.where = {"type": global.PromptTypes.string, "default": ""}

var childBlocks = []

func on_respawn():
  for thing in childBlocks:
    var node: EditorBlock = thing[0]
    var data: Dictionary = thing[1]

    node.startPosition = Vector2(data.x, data.y) + startPosition
    node.startRotation_degrees = data.r + startRotation_degrees
    node.startScale = Vector2(data.w, data.h) * startScale/7.0
    node.respawn()

func on_ready() -> void:
  log.pp(global.path.abs(
    "res://maps/" +
    global.mainLevelName +
    "/custom blocks/" +
    selectedOptions.where
    + ".sds"
  ))
  if !selectedOptions.where: return
  var blockData = sds.loadDataFromFile(
    global.path.abs(
      "res://maps/" +
      global.mainLevelName +
      "/custom blocks/" +
      selectedOptions.where
      + ".sds"
    )
  )
  for thing in childBlocks:
    var node: EditorBlock = thing[0]
    if is_instance_valid(node):
      node.queue_free.call_deferred()
  if !blockData:
    log.err("Could not load data from " + selectedOptions.where)
    return
  childBlocks = []
  for block in blockData:
    var node := global.createNewBlock(block)
    childBlocks.append([node, block])
    node.EDITOR_IGNORE = true
    add_child(node)
  on_respawn()

# func on_physics_process(delta: float) -> void:
#   for node in childBlocks:
#     node.global_position = node.startPosition + startPosition
