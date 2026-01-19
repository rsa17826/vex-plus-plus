@icon("images/1.png")
extends EditorBlock
class_name BlockChain

var thingsInside: Array[EditorBlock] = []

func _init() -> void:
  # global.attachChildAdded.connect(attachChildAdded)
  global.player.Alltryaddgroups.connect(a)

func a():
  await global.wait()
# func attachChildAdded(block: EditorBlock, _child: EditorBlock):
  var merged := collect_attachment_group(attach_children)

  for child in attach_children:
    child.attach_parents.erase(self)
    for other in merged:
      if other != child:
        if other not in self.attach_parents:
          self.attach_parents.append(other)
        if self not in other.attach_children:
          other.attach_children.append(self)
        if child not in other.attach_children:
          other.attach_children.append(child)
        log.pp(child, other, child in other.attach_children)
        if other not in child.attach_parents:
          child.attach_parents.append(other)
    # log.pp(child.id, child.attach_parents.map(func(e): return e.id))

func collect_attachment_group(start_nodes: Array) -> Array:
  var out = []
  for node in start_nodes:
    if node == self: continue

    for parent in node.attach_parents:
      if parent != self and parent not in out:
        out.append(parent)

  return out
