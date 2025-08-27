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
    'id': id
  }
  if !ResourceLoader.exists("res://scenes/blocks/" + id + "/main.tscn"):
    log.err("Error: Block " + id + " is not a valid block id!")
    return false
  thing.options = {}
  for k in selectedOptions:
    if k != 'fakeId':
      thing.options[k] = selectedOptions[k]
  thing.id = id
  global.level.get_node("blocks").add_child(global.createNewBlock(thing))
  queue_free.call_deferred()
  return true