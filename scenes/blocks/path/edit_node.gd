extends EditorBlock
class_name BlockPath_editNode

var moving = false
var path: EditorBlock

func onEditorMove(moveDist) -> void:
  moving = true

func on_process(delta):
  if moving:
    path.updatePoint(self , !respawning)