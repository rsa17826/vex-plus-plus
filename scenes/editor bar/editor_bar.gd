extends Node2D

var nodeSize: float
var scrollOffset: float = 0
var nodeCount: int = 0

@onready var columns: int = global.useropts.editorBarColumns
var nodeScrollOnY: bool
var nodeScrollOnX: bool

const defaultEditorBarIcon := preload("res://scenes/blocks/image.png")

func _init() -> void:
  global.editorBar = self

func _ready() -> void:
  global.overlays.append(self )
  global.onEditorStateChanged.connect(func(): visible = global.showEditorUi)
  global.defaultBlockOpts = sds.loadDataFromFile("user://defaultBlockOpts.sds", {})
  position.x = global.useropts.editorBarOffset
  for item in get_children():
    if item not in [$item, $ColorRect]:
      item.queue_free()
  nodeCount = 0
  nodeSize = global.useropts.editorBarBlockSize
  $item.visible = true
  var invalidCount = 0
  for i in range(0, len(global.blockNames)):
    if not newItem(global.blockNames[i], i - invalidCount) and not global.useropts.reorganizingEditorBar:
      invalidCount += 1
  for item in get_children():
    updateItem(item)
  $item.visible = false
  $ColorRect.size = Vector2((columns * nodeSize), nodeSize * ceil(nodeCount / float(columns)))
  nodeScrollOnX = nodeSize * columns > global.windowSize.x
  nodeScrollOnY = (nodeSize * ceil(nodeCount / float(columns))) > global.windowSize.y
  if columns > nodeCount:
    columns = nodeCount
  scrollOffset = 0
  updateScrollPos()
  log.pp(global.useropts.editorBarPosition, "global.useropts.editorBarPosition")
  match global.useropts.editorBarPosition:
    0:
      position = Vector2.ZERO
    1:
      position = Vector2(0, global.windowSize.y - $ColorRect.size.y)
    2:
      position = Vector2(global.windowSize.x - $ColorRect.size.x, 0)
  position.y += global.useropts.editorBarOffset

func updateScrollPos():
  if nodeScrollOnY:
    var visibleNodesY = floor(float(global.windowSize.y) / nodeSize) * nodeSize
    var maxScroll = max(0, (nodeSize * ceil(nodeCount / float(columns))) - (visibleNodesY))
    scrollOffset = clamp(scrollOffset, 0, maxScroll)
  if nodeScrollOnX:
    var visibleNodesX = floor(global.windowSize.x / nodeSize) * nodeSize
    log.pp(visibleNodesX)
    log.pp(min(columns, nodeCount))
    var maxScroll = max(0, (nodeSize * ceil(columns)) - visibleNodesX)
    scrollOffset = clamp(scrollOffset, 0, maxScroll)

func _input(event: InputEvent) -> void:
  if global.openMsgBoxCount: return
  if event is InputEventMouseButton:
    if event.is_pressed():
      if event.button_index == MOUSE_BUTTON_WHEEL_UP:
        scrollOffset -= nodeSize * (global.useropts.editorBarScrollSpeed)
      if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
        scrollOffset += nodeSize * (global.useropts.editorBarScrollSpeed)
      updateScrollPos()
      # else:
      #   scrollOffset = clamp(scrollOffset, 0, nodeSize * ceil(nodeCount / float(columns)))

      for item in get_children():
        updateItem(item)

func newItem(name, id) -> bool:
  var nodeFound = true
  if name == null:
    nodeCount += 1
    return nodeFound
  var icon = Sprite2D.new()
  var item = $item.duplicate()
  if name is String:
    var clone
    if FileAccess.file_exists("res://scenes/blocks/" + name + "/main.tscn"):
      clone = load("res://scenes/blocks/" + name + "/main.tscn")
      clone = clone.instantiate()
      if 'editorBarIcon' not in clone or not clone.editorBarIcon:
        log.err("clone.editorBarIcon not found", clone.name, id, name)
        breakpoint
    else:
      nodeCount -= 1
      nodeFound = false
      if global.useropts.showEditorBarBlockMissingErrors:
        log.err(name, "block not found", id, name)
    icon.texture = clone.editorBarIcon if clone else defaultEditorBarIcon
    item.add_child(icon)
    item.id = id
    item.blockName = name
    if clone:
      clone.queue_free.call_deferred()
  elif name is Dictionary:
    var im := Image.new()
    im.load(name.imagePath)
    if im.is_empty():
      icon.texture = defaultEditorBarIcon
      nodeFound = false
    else:
      icon.texture = ImageTexture.create_from_image(im)
    item.add_child(icon)
    item.id = id
    item.blockName = name.extends
    item.blockData = name

  nodeCount += 1
  var origSize = icon.texture.get_size() * icon.scale
  var maxSize = max(origSize.x, origSize.y)
  var scaleFactor = max(icon.scale.x, icon.scale.y) * (700 / maxSize)
  icon.scale = Vector2(
    scaleFactor,
    scaleFactor
  )
  if not nodeFound \
  and not global.useropts.showEditorBarBlockMissingErrors\
  and not global.useropts.reorganizingEditorBar:
    return false
  add_child(item)
  updateItem(item)
  global.lastSelectedBrush = item
  return nodeFound

func updateItem(item):
  if item == $ColorRect: return
  item.scale = (Vector2(1, 1) / 7)

  item.scale *= (float(nodeSize) / 100)
  item.scale /= 1.1
  item.normalScale = item.scale
  if item.selected:
    item.scale *= 1.1

  # Calculate the column and row based on the item ID
  var column: float = item.id % columns # Column index
  var row = item.id / columns # Row index

  item.position = Vector2(column * nodeSize, row * nodeSize) \
  + Vector2(nodeSize, nodeSize) / 2

  if nodeScrollOnX:
    item.position -= Vector2(scrollOffset, 0)
  if nodeScrollOnY:
    item.position -= Vector2(0, scrollOffset)
