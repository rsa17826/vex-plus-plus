extends EditorBlock
class_name BlockPath_editNode

var moving = false
var path: EditorBlock

func onEditorMove(moveDist) -> void:
  moving = true

func on_ready() -> void:
  if not global.onEditorStateChanged.is_connected(updateVisible):
    global.onEditorStateChanged.connect(updateVisible)
  
func updateVisible():
  visible = global.useropts.showPathEditNodesInPlay or global.showEditorUi

func on_respawn():
  updateVisible()

func on_process(delta):
  if moving:
    path.updatePoint(self , !respawning)