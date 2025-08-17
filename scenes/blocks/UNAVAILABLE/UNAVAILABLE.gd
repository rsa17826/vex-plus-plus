@icon("images/1.png")
extends EditorBlock
class_name BlockUnavailable

func generateBlockOpts():
  blockOptions.fakeId = {
    'type': global.PromptTypes.string,
    'default': "unavailable",
    "onChange": onIdChanged
  }

func onIdChanged(id):
  var thing = {
    'x': startPosition.x,
    'y': startPosition.y,
    'w': startScale.x,
    'h': startScale.y,
    'r': startRotation_degrees,
    'id': selectedOptions.fakeId
  }
  if FileAccess.file_exists("res://scenes/blocks/" + thing.id + "/main.tscn"):
    log.err("Error: Block " + thing.id + " is not a valid block id!")
    return
  thing.fakeId = thing.id
  thing.options = {}
  for k in selectedOptions:
    if k != 'fakeId':
      thing.options[k] = selectedOptions[k]
  thing.id = selectedOptions.fakeId
  global.level.get_node("blocks").add_child(global.createNewBlock(thing))
  return true