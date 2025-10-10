@icon("images/editorBar.png")
extends EditorBlock
class_name BlockAndGate

@export var labelInpa: Label
@export var labelInpb: Label
@export var labelOut: Label

var aon = false
var bon = true

func generateBlockOpts():
  blockOptions.signalAInputId = {"type": global.PromptTypes.int, "default": 0}
  blockOptions.signalBInputId = {"type": global.PromptTypes.int, "default": 0}
  blockOptions.signalOutputId = {"type": global.PromptTypes.int, "default": 0}

func on_respawn():
  global.onSignalChanged(onSignalChanged)
  labelInpa.text = str(selectedOptions.signalAInputId)
  labelInpb.text = str(selectedOptions.signalBInputId)
  labelOut.text = str(selectedOptions.signalOutputId)
  global.sendSignal(selectedOptions.signalOutputId, self , false)

func onSignalChanged(id, on, callers):
  if self in callers: return
  if id not in [selectedOptions.signalAInputId, selectedOptions.signalBInputId]: return
  if id == selectedOptions.signalAInputId:
    aon = on
  elif id == selectedOptions.signalBInputId:
    bon = on
  global.sendSignal(selectedOptions.signalOutputId, self , aon and bon)

func onDelete():
  global.sendSignal(selectedOptions.signalOutputId, self , false)

# func getConnectedBlocks():
#   global.level.get_node("blocks").get_children() \
#   .filter(
#     func(e):
#       var found=0
#       for thing in ['signalAInputId', 'signalBInputId', 'signalInputId']:
#         if thing in e.selectedOptions \
#         and e.selectedOptions[thing] == selectedOptions.signalOutputId:
#           found=1
#           if e.selectedOptions[thing] in global.activeSignals \
#           and global.activeSignals[e.selectedOptions[thing]]:
#             found=2
#             break
#       return found
#   )
