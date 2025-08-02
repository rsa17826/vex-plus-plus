extends EditorBlock
class_name BlockPath_editNode

var moving = false
var path: BlockPath

func onEditorMove(moveDist) -> void:
  super (moveDist)
  moving = true

func on_ready() -> void:
  if not global.onEditorStateChanged.is_connected(updateVisible):
    global.onEditorStateChanged.connect(updateVisible)

func updateVisible():
  visible = global.useropts.showPathEditNodesInPlay or global.showEditorUi

func on_respawn():
  updateVisible()

func on_process(delta):
  if not global.isAlive(path):
    queue_free()
    return
  if moving:
    path.updatePoint(self , !respawning)

func generateBlockOpts():
  blockOptions.addNewPoint = {
    "type": 'BUTTON',
    "onChange": func():
      var idx = path.pathEditNodes.find(self )
      path.path.insert(idx + 1, path.path[idx])
      path.updatePoint(self , true)
  }

func onDelete():
  if !global.isAlive(path): return
  var idx = path.pathEditNodes.find(self )
  path.pathEditNodes.erase(self )
  path.path.remove_at(idx + 1)
  path.savePath()
  path.respawn.call_deferred()