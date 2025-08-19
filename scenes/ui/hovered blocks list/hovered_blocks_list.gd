extends Control

@export var listElem: Control
@export var ttm: Control

var labels := []

func _process(delta: float) -> void:
  ttm.visible = true
  if not global.useropts.showHoveredBlocksList or not global.showEditorUi or not global.hoveredBlocks:
    ttm.visible = false
    return
  while len(global.hoveredBlocks) > len(labels):
    var l = Label.new()
    labels.append(l)
    listElem.add_child(l)
  if global.selectedBlock:
    %selectedBlock.text = global.selectedBlock.id
    %selectedBlock.get_parent().visible = true
  else:
    %selectedBlock.get_parent().visible = false
  var i = 0
  for label in labels:
    if i >= len(global.hoveredBlocks):
      label.visible = false
    else:
      label.visible = true
      labels[i].text = global.hoveredBlocks[i].id
    i += 1
  ttm.position = get_local_mouse_position() + Vector2(20, 20)