extends VBoxContainer

func _ready():
  global.onSignalChanged(onSignalChanged)
func _process(delta):
  global.onSignalChanged(onSignalChanged)
var signalList := {}

const ON = preload("res://scenes/ui/images/on.png")
const OFF = preload("res://scenes/ui/images/off.png")

func onSignalChanged(id, on):
  if id not in signalList:
    signalList[id] = $signalDisplay.duplicate()
    # var label := Label.new()
    # label.name = "signal id"
    # signalList[id].add_child(label)
    add_child(signalList[id])
    signalList[id].visible = true
    signalList[id].get_node("signal id").text = str(id)

  var blockImages := {}
  signalList[id].get_node("image").texture = ON if on else OFF
  signalList[id].get_node("count").text = str(len(global.activeSignals[id]))
  for block in global.activeSignals[id]:
    if block.id not in blockImages:
      blockImages[block.id] = {'count': 0, 'ghost': block.ghost}
    blockImages[block.id].count += 1

  for blockImageNode in signalList[id].blockImages:
    blockImageNode.queue_free()
  signalList[id].blockImages = []

  for blockId in blockImages:
    var blockImageNode = $signalDisplay.duplicate()
    blockImageNode.visible = true
    signalList[id].add_child(blockImageNode)
    signalList[id].blockImages.append(blockImageNode)
    blockImageNode.get_node("count").text = str(blockImages[blockId].count)
    blockImageNode.get_node("image").texture = blockImages[blockId].ghost.texture