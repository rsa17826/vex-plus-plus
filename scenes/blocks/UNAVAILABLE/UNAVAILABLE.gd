@icon("images/1.png")
extends EditorBlock
class_name BlockUnavailable
var fakeId: String = "unavailable"

func generateBlockOpts():
  blockOptions.fakeId = {'type': global.PromptTypes.string, 'default': fakeId}