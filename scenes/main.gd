extends Control

var containers: Array[FoldableContainer] = []

func _init() -> void:
  global.tabMenu = self

func _input(event: InputEvent) -> void:
  if event is InputEventKey:
    if Input.is_action_just_pressed(&"toggle_tab_menu", true):
      visible = !visible

func _ready() -> void:
  global.fullscreen(-1)
  containers = getChildren()
  var data = sds.loadDataFromFile("user://tab_menu.sds", [])
  var i = 0
  for container in containers:
    container.folded = data[i] if len(data) > i else false
    i += 1

func getChildren(startNode: Control = self ) -> Array[FoldableContainer]:
  var nested_searchables: Array[FoldableContainer] = []
  for child in startNode.get_children():
    if child is FoldableContainer:
      nested_searchables.append(child)
    else:
      nested_searchables += getChildren(child)
  return nested_searchables

func saveFoldingState():
  var data = containers.map(func(e): return e.folded)
  sds.saveDataToFile("user://tab_menu.sds", data)
