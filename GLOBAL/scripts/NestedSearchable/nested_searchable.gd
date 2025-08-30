extends Control
class_name NestedSearchable

@export var thisText: String

signal searchMatchedThis
signal searchMatchedChildren
signal searchCleared

func getChildNestedSearchables(startNode: Control = self ) -> Array[NestedSearchable]:
  var nested_searchables: Array[NestedSearchable] = []
  for child in startNode.get_children():
    if child is NestedSearchable:
      nested_searchables.append(child)
    else:
      nested_searchables += getChildNestedSearchables(child)
  return nested_searchables

func updateSearch(search: String, parentText: String = '', nested_searchable_parents:=[]):
  visible = false
  for item in getChildNestedSearchables():
    item.updateSearch(search, thisText, nested_searchable_parents + [ self ])
  if not search:
    visible = true
    searchCleared.emit()
    return
  if search in thisText:
    searchMatchedThis.emit()
    showChildren()
  if search in parentText or search in thisText:
    visible = true
    for item in nested_searchable_parents:
      item.visible = true
      item.searchMatchedChildren.emit()

func showChildren():
  visible = true
  for node in getChildNestedSearchables():
    node.showChildren()
    node.searchMatchedChildren.emit()