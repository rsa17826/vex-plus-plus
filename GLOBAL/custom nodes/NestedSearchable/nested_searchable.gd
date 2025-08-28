extends Control
class_name NestedSearchable

@export var thisText: String

func updateSearch(search: String, parentText: String = ''):
  visible = false
  for item in get_children():
    if item is NestedSearchable:
      item.updateSearch(search, thisText)
  if search in parentText:
    showChildren()
  if search in thisText:
    var node = self
    while 1:
      node.visible = true
      node = node.get_parent()
      if !node or (not (node is NestedSearchable)): break

func showChildren():
  visible = true
  for item in get_children():
    if item is NestedSearchable:
      item.showChildren()