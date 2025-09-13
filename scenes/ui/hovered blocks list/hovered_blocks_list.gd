extends Control

@export var listElem: Control
@export var ttm: Control

var labels := []

func _process(delta: float) -> void:
  if global.hideAllOverlays:
    ttm.visible = false
    return
  ttm.visible = true
  if global.openMsgBoxCount \
    or not global.useropts.showHoveredBlocksList \
    or not global.showEditorUi \
    or not (
      global.hoveredBlocks \
      or global.selectedBlock
    ) \
  :
    ttm.visible = false
    return
  var blocks = global.hoveredBlocks.filter(func(e): return e != global.selectedBlock)
  while len(blocks) > len(labels):
    var l = Label.new()
    labels.append(l)
    listElem.add_child(l)
  if global.selectedBlock:
    %selectedBlock.text = getBlockData(global.selectedBlock, true)
    %selectedBlock.visible = !!%selectedBlock.text
  else:
    %selectedBlock.visible = false
  %HSeparator.visible = blocks and global.selectedBlock
  var i = 0
  for label in labels:
    if i >= len(blocks):
      label.visible = false
    else:
      label.visible = true
      labels[i].text = getBlockData(blocks[i], false)
      if not label.text:
        label.visible = false
    i += 1
  ttm.position = get_local_mouse_position() + Vector2(20, 20)

func getBlockData(block: EditorBlock, isSelected: bool) -> String:
  var table = {
    'pxx': str(int(block.sizeInPx.x)),
    'pxy': str(int(block.sizeInPx.y)),
    'sx': '%.3f' % (block.scale.x),
    'sy': '%.3f' % (block.scale.y),
    'posx': str(int(block.startPosition.x)),
    'posy': str(int(block.startPosition.y)),
    'rot': str(int(block.startRotation_degrees)),
    'id': block.id
  }
  return (global.useropts.selectedBlockFormatString if isSelected else global.useropts.hoveredBlockFormatString).format(table)