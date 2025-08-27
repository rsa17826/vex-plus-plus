extends VBoxContainer

func _ready():
  visible = global.useropts.showSignalList

var listOfLoadedSignals := {}

const ON = preload("res://scenes/ui/images/on.png")
const OFF = preload("res://scenes/ui/images/off.png")

func removeSignal(id):
  if id not in listOfLoadedSignals: return
  listOfLoadedSignals[id].queue_free()
  listOfLoadedSignals.erase(id)

func onSignalChanged(id, on, callers):
  if self in callers: return
  if !global.useropts.showSignalList: return
  if id not in listOfLoadedSignals:
    if len(listOfLoadedSignals) > 50: return
    listOfLoadedSignals[id] = $signalDisplay.duplicate()
    add_child(listOfLoadedSignals[id])
    listOfLoadedSignals[id].visible = true
    listOfLoadedSignals[id].get_node("signal id").text = 'ID: ' + str(id)

  var blockData := {}
  if global.useropts.onlyShowActiveSignals:
    if not on:
      listOfLoadedSignals[id].visible = false
      return
    listOfLoadedSignals[id].visible = true
  else:
    listOfLoadedSignals[id].get_node("image").texture = ON if on else OFF
  if global.useropts.showTotalActiveSignalCounts:
    listOfLoadedSignals[id].get_node("count").text = str(len(global.activeSignals[id]))
  for block in global.activeSignals[id]:
    if block.id not in blockData:
      blockData[block.id] = {'count': 0, 'block': block}
    blockData[block.id].count += 1

  if global.useropts.showWhatBlocksAreSendingSignals:
    for blockImageNode in listOfLoadedSignals[id].blockImages:
      blockImageNode.queue_free()
    listOfLoadedSignals[id].blockImages = []

    for i in blockData:
      var blockImageNode = $signalDisplay.duplicate()
      blockImageNode.get_node("signal id").queue_free()
      blockImageNode.visible = true
      listOfLoadedSignals[id].add_child(blockImageNode)
      listOfLoadedSignals[id].blockImages.append(blockImageNode)
      blockImageNode.get_node("count").text = str(blockData[i].count)
      blockImageNode.get_node("image").texture = blockData[i].block.editorBarIcon