extends Node2D
# @name same line return
# @regex :\s*return(\s*.{0,10})$
# @replace : return$1
# @flags gm
# @endregex

var rowSize
var nodeSize
var scaleY = true
var scrollSpeed
var xoffset = 0
var nodeCount = 0

@export var maxId = 0
func _ready() -> void:
  nodeSize = global.useropts.blockPickerBlockSize
  scrollSpeed = nodeSize
  var screenSize = DisplayServer.window_get_size().x
  for item in get_children():
    if item != $item and item != $ColorRect:
      item.queue_free()
  await global.wait()
  $item.visible = true
  rowSize = floor(screenSize / nodeSize)
  var extraSize = screenSize - (rowSize * nodeSize)
  scale.x = 1 + global.rerange(extraSize, 0, screenSize, 0, 1)
  if scaleY:
    scale.y = scale.x
  $ColorRect.size = Vector2(screenSize, nodeSize * (1 + ((1 - scale.y) / 2)) * 1.05)
  for i in range(0, len(global.blockNames)):
    newItem(global.blockNames[i], i)
  xoffset = clamp(xoffset, 0, (nodeSize * nodeCount) - nodeSize * rowSize)
  for item in get_children():
    updateItem(item)
  $item.visible = false

func _process(delta: float) -> void:
  visible = global.showEditorUi

func _input(event: InputEvent) -> void:
  if event is InputEventMouseButton:
    if event.is_pressed():
      if event.button_index == MOUSE_BUTTON_WHEEL_UP:
        xoffset += scrollSpeed
      if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
        xoffset -= scrollSpeed
      xoffset = clamp(xoffset, 0, (nodeSize * nodeCount) - nodeSize * rowSize)
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
  clone.queue_free()
  add_child(item)
  updateItem(item)

func updateItem(item):
  if item.name == "ColorRect": return
  item.scale = (Vector2(1, 1) / 7)

  if scaleY:
    item.scale *= (float(nodeSize) / 100)
  else:
    item.scale.x *= (float(nodeSize) / 100)
  item.scale /= 1.1
  item.normalScale = item.scale
  if item.selected:
    item.scale *= 1.1

  item.position = Vector2(float(nodeSize) * ((item.id - 1)), 0) + Vector2((nodeSize / 2) + nodeSize, (nodeSize / 2))
  item.position -= Vector2(xoffset, 0)
