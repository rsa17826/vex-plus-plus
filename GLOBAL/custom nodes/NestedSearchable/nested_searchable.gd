extends Control
class_name NestedSearchable

@export var thisText: String
@export var SPLITTER := "\u1562"

func updateSearch(search: String, parentText: String = ''):
  visible = false
  for item in get_children():
    if item is NestedSearchable:
      item.updateSearch(search, thisText)
  if search in parentText:
    visible = true
    showChildren()
  if search in thisText:
    visible = true
    var node = self
    while 1:
      node = node.get_parent()
      if !node or (not (node is NestedSearchable)): break
      node.visible = true

func showChildren():
  for item in get_children():
    if item is NestedSearchable:
      item.visible = true
      item.showChildren()