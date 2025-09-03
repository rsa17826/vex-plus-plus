extends Control

@export var listElem: Control
@export var ttm: Control

var labels := []

func _process(delta: float) -> void:
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

func getBlockData(block, isSelected):
  return (getId(block, isSelected) + getPos(block, isSelected) + getRot(block, isSelected)).strip_edges()

func getId(block, isSelected):
  if isSelected:
    if not global.useropts.showSelectedBlockId:
      return ''
  else:
    if not global.useropts.showHoveredBlockId:
      return ''
  return block.id
func getPos(block, isSelected):
  if isSelected:
    if not global.useropts.showSelectedBlockPosition:
      return ''
  else:
    if not global.useropts.showHoveredBlockPosition:
      return ''
  return " (" + str(int(block.startPosition.x)) + ', ' + str(int(block.startPosition.y)) + ")"
func getRot(block, isSelected):
  if isSelected:
    if not global.useropts.showSelectedBlockRotation:
      return ''
  else:
    if not global.useropts.showHoveredBlockRotation:
      return ''
  return " R" + str(int(block.startRotation_degrees))