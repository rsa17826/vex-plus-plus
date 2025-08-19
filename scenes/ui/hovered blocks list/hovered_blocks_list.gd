extends Control

@export var listElem: Control
@export var ttm: Control

var labels := []

func _process(delta: float) -> void:
  ttm.visible = true
  if not global.useropts.showHoveredBlocksList or not global.showEditorUi or not (global.hoveredBlocks or global.selectedBlock):
    ttm.visible = false
    return
  var blocks = global.hoveredBlocks.filter(func(e): return e != global.selectedBlock)
  while len(blocks) > len(labels):
    var l = Label.new()
    labels.append(l)
    listElem.add_child(l)
  if global.selectedBlock:
    %selectedBlock.text = global.selectedBlock.id
    %selectedBlock.visible = true
  else:
    %selectedBlock.visible = false
  %HSeparator.visible = blocks and global.selectedBlock
  var i = 0
  for label in labels:
    if i >= len(blocks):
      label.visible = false
    else:
      label.visible = true
      labels[i].text = blocks[i].id
    i += 1
  ttm.position = get_local_mouse_position() + Vector2(20, 20)