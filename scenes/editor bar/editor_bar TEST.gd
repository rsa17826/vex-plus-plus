extends Node2D

var nodeSize: float
var scrollOffset: Vector2 = Vector2.ZERO
var nodeCount: int = 0

var rows: int
var columnsVisible: int = 4
var columns: int = 8

func _ready() -> void:
  global.defaultBlockOpts = sds.loadDataFromFile("user://defaultBlockOpts.sds", {})
  position.x = global.useropts.editorBarOffset
  for item in get_children():
    if item not in [$item, $ColorRect]:
      item.queue_free()
  nodeCount = 0
  nodeSize = global.useropts.editorBarBlockSize
  $item.visible = true
  $ColorRect.size = Vector2((columnsVisible * nodeSize), (rows * nodeSize)) # Adjusted for width and height
  for i in range(0, len(global.blockNames)):
    newItem(global.blockNames[i], i)

  # Calculate the maximum scrollable area
  var maxScrollX = max(0, (nodeSize * nodeCount) - (nodeSize * columnsVisible))
  var maxScrollY = max(0, (nodeSize * ceil(nodeCount / float(columns))) - (nodeSize * rows))

  scrollOffset.x = clamp(scrollOffset.x, 0, maxScrollX) # Horizontal clamp
  scrollOffset.y = clamp(scrollOffset.y, 0, maxScrollY) # Vertical clamp

  for item in get_children():
    updateItem(item)
  $item.visible = false
  rows = ceil(nodeCount / float(columns))
  log.pp(rows)

func _input(event: InputEvent) -> void:
  if event is InputEventMouseButton:
    if event.is_pressed():
      if Input.is_key_pressed(KEY_SHIFT):
        if event.button_index == MOUSE_BUTTON_WHEEL_UP: # Scroll left
          scrollOffset.x = clamp(scrollOffset.x - nodeSize * (global.useropts.editorBarScrollSpeed), 0, (nodeSize * nodeCount) - (nodeSize * columnsVisible))
        if event.button_index == MOUSE_BUTTON_WHEEL_DOWN: # Scroll right
          scrollOffset.x = clamp(scrollOffset.x + nodeSize * (global.useropts.editorBarScrollSpeed), 0, (nodeSize * nodeCount) - (nodeSize * columnsVisible))
      else:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
          scrollOffset.y = clamp(scrollOffset.y + nodeSize * (global.useropts.editorBarScrollSpeed), 0, (nodeSize * ceil(nodeCount / float(columns))) - (nodeSize * rows)) # Scroll up
        if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
          scrollOffset.y = clamp(scrollOffset.y - nodeSize * (global.useropts.editorBarScrollSpeed), 0, (nodeSize * ceil(nodeCount / float(columns))) - (nodeSize * rows)) # Scroll down
      var maxScrollX = max(0, (nodeSize * nodeCount) - (nodeSize * columnsVisible))
      var maxScrollY = max(0, (nodeSize * ceil(nodeCount / float(columns))) - (nodeSize * rows))

      scrollOffset.x = clamp(scrollOffset.x, 0, maxScrollX) # Horizontal clamp
      scrollOffset.y = clamp(scrollOffset.y, 0, maxScrollY) # Vertical clamp
      for item in get_children():
        updateItem(item)

func _process(delta: float) -> void:
  visible = global.showEditorUi

func newItem(name, id) -> void:
  var clone = load("res://scenes/blocks/" + name + "/main.tscn")
  if !clone: return
  nodeCount += 1
  clone = clone.instantiate()
  var item = $item.duplicate()
  if 'editorBarIconNode' not in clone or not clone.editorBarIconNode:
    log.err("clone.editorBarIconNode not found", clone.name, id, name)
    breakpoint
  var icon = clone.editorBarIconNode.duplicate()
  icon.visible = true
  item.add_child(icon)
  item.id = id
  item.blockName = name
  var origSize = icon.texture.get_size() * icon.scale
  var maxSize = max(origSize.x, origSize.y)
  var scaleFactor = max(icon.scale.x, icon.scale.y) * (700 / maxSize)
  icon.scale = Vector2(
    scaleFactor,
    scaleFactor
  )

  clone.queue_free()
  add_child(item)
  updateItem(item)
  global.lastSelectedBrush = item

func updateItem(item):
  if item.name == "ColorRect": return
  item.scale = (Vector2(1, 1) / 7)

  item.scale *= (float(nodeSize) / 100) # Adjust for vertical scaling
  item.scale /= 1.1
  item.normalScale = item.scale
  if item.selected:
    item.scale *= 1.1

  # Calculate the column and row based on the item ID
  var column: float = item.id % columns # Column index
  var row = item.id / columns # Row index
  var scrollColumn: float = scrollOffset.x / nodeSize
  if column < scrollColumn or column > scrollColumn + columnsVisible - 1:
    item.visible = false
  else:
    item.visible = true
  # Update the item's position based on the column and row, including the scroll offsets
  item.position = Vector2(column * nodeSize, row * nodeSize) \
    + Vector2(nodeSize, nodeSize) / 2
  item.position -= scrollOffset # Apply both horizontal and vertical scroll offsets
