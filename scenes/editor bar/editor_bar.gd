extends Node2D
# @name same line return
# @regex :\s*return(\s*.{0,10})$
# @replace : return$1
# @flags gm
# @endregex

var nodeSize: float
var scrollOffset: float = 0
var nodeCount: int = 0

var rows: int = 12

func _ready() -> void:
  global.defaultBlockOpts = sds.loadDataFromFile("user://defaultBlockOpts.sds", {})
  position.x = global.useropts.editorBarOffset
  for item in get_children():
    if item not in [$item, $ColorRect]:
      item.queue_free()
  nodeCount = 0
  nodeSize = global.useropts.blockPickerBlockSize
  var screenSize = global.windowSize.y
  $item.visible = true
  var extraSize = screenSize - (rows * nodeSize)
  scale.y = 1 + global.rerange(extraSize, 0, screenSize, 0, 1)
  scale.x = scale.y
  $ColorRect.size = Vector2((rows * nodeSize), screenSize)
  for i in range(0, len(global.blockNames)):
    newItem(global.blockNames[i], i)
  scrollOffset = clamp(scrollOffset, 0, (nodeSize * nodeCount) - nodeSize * rows)
  for item in get_children():
    updateItem(item)
  $item.visible = false

func _process(delta: float) -> void:
  visible = global.showEditorUi

func _input(event: InputEvent) -> void:
  if event is InputEventMouseButton:
    if event.is_pressed():
      if event.button_index == MOUSE_BUTTON_WHEEL_UP:
        scrollOffset += nodeSize * (global.useropts.editorBarScrollSpeed)
      if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
        scrollOffset -= nodeSize * (global.useropts.editorBarScrollSpeed)
      var offset = ceil(nodeCount / float(rows))
      log.pp(offset)
      scrollOffset = clamp(scrollOffset, 0, ((nodeSize * offset) - nodeSize * rows))
      for item in get_children():
        updateItem(item)

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
  var column: float = item.id % rows # Column index
  var row = item.id / rows # Row index

  item.position = Vector2(column * nodeSize, row * nodeSize) \
  + Vector2(nodeSize, nodeSize) / 2
  item.position -= Vector2(0, scrollOffset)
