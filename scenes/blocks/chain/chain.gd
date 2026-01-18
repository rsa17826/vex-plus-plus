@icon("images/1.png")
extends EditorBlock
class_name BlockChain

var thingsInside: Array[EditorBlock] = []

# func on_respawn() -> void:
#   await global.wait(1000)
#   log.pp("sdkjldsjkfkldsfjklsdflk")
#   var newChildren:Array=[]
#   for child in attach_children:
#     newChildren+=child.attach_parents.filter(func(e): return e != self)
#   for child in attach_children:
#     child.attach_parents.append_array(newChildren)
#     log.pp(child.attach_parents)
#   # log.pp(attach_children, attach_parents)
func _init() -> void:
  global.attachChildAdded.connect(attachChildAdded)
  global.attachParentAdded.connect(attachParentAdded)
var watchedBlocks = []
var childrenToAppend = []
var childrenToAppendTo = []
func attachChildAdded(block: EditorBlock, child: EditorBlock):
  if block == self:
    watchedBlocks.append(child)
    for node in child.attach_parents:
      if node not in childrenToAppend:
        childrenToAppend.append(node)
    log.pp(childrenToAppend)
    # log.pp(child.attach_children, child.attach_parents)
  # log.pp(block, child, "child", block == self, child == self)
func attachParentAdded(block: EditorBlock, parent: EditorBlock):
  log.pp(block, parent, "parent", block in watchedBlocks, parent == self)
