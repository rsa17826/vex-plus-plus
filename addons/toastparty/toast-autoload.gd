extends Node

const label_resource = preload("toast_label/toast_label.tscn")

var label_top_left = []
var label_top_right = []
var label_bottom_left = []
var label_bottom_right = []

var label_top_center = []
var label_bottom_center = []

# parent node
var canvas_layer: CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
  canvas_layer = CanvasLayer.new()
  canvas_layer.set_name("ToastPartyLayer")
  canvas_layer.layer = 128
  add_child(canvas_layer)

  # TODO: We need Debounce function
  # Connect signal resize to _on_resize
  # get_tree().get_root().connect("size_changed", _on_resize, 1)

func _add_new_label(config):
  # Create a new label
  var label = label_resource.instantiate()
  canvas_layer.add_child(label)
  label.connect("remove_label", remove_label_from_array)
  label.remove_label.connect(func(...a):
    move_positions(config.direction, config.gravity, false)
    move_positions.call_deferred(config.direction, config.gravity, false)
  )

  if config.direction == "left":
    if config.gravity == "top":
      label_top_left.insert(0, label)
    else:
      label_bottom_left.insert(0, label)
  elif config.direction == "center":
    if config.gravity == "top":
      label_top_center.insert(0, label)
    else:
      label_bottom_center.insert(0, label)
  else:
    if config.gravity == "top":
      label_top_right.insert(0, label)
    else:
      label_bottom_right.insert(0, label)

  # Configuration of the label
  label.init(config)

  # Move all labels to new positions when a new label is added
  move_positions(config.direction, config.gravity, true)

func move_positions(direction, gravity, animate):
  if direction == "left" and gravity == "bottom":
    for index in label_bottom_left.size():
      var _label = label_bottom_left[index]
      _label.move_to(label_bottom_left.size() - 1 - index, animate && index == 0)

  elif direction == "left" and gravity == "top":
    for index in label_top_left.size():
      var _label = label_top_left[index]
      _label.move_to(label_top_left.size() - 1 - index, animate && index == 0)

  elif direction == "right" and gravity == "bottom":
    for index in label_bottom_right.size():
      var _label = label_bottom_right[index]
      _label.move_to(label_bottom_right.size() - 1 - index, animate && index == 0)

  elif direction == "right" and gravity == "top":
    for index in label_top_right.size():
      var _label = label_top_right[index]
      _label.move_to(label_top_right.size() - 1 - index, animate && index == 0)

  elif direction == "center" and gravity == "bottom":
    for index in label_bottom_center.size():
      var _label = label_bottom_center[index]
      _label.move_to(label_bottom_center.size() - 1 - index, animate && index == 0)

  elif direction == "center" and gravity == "top":
    for index in label_top_center.size():
      var _label = label_top_center[index]
      _label.move_to(label_top_center.size() - 1 - index, animate && index == 0)

func remove_label_from_array(label):
  if label.direction == "left":
    if label.gravity == "top":
      label_top_left.erase(label)
    else:
      label_bottom_left.erase(label)
  elif label.direction == "center":
    if label.gravity == "top":
      label_top_center.erase(label)
    else:
      label_bottom_center.erase(label)
  else:
    if label.gravity == "top":
      label_top_right.erase(label)
    else:
      label_bottom_right.erase(label)

## Event resize
func _on_resize():
  var toast_labels = label_top_left + label_top_right + label_bottom_left + label_bottom_right + label_top_center + label_bottom_center
  for _label in toast_labels:
    _label.update_x_position()

func clean_config(config):
  if not config.has("text"):
    config.text = "🥑 toast party! 🥑"

  if not config.has("direction"):
    config.direction = "right"

  if not config.has("gravity"):
    config.gravity = "top"

  if not config.has("bgcolor"):
    config.bgcolor = Color(0, 0, 0, 0.7)

  if not config.has("color"):
    config.color = Color(1, 1, 1, 1)

  return config

func show(config={}):
  var _config_cleaned = clean_config(config)
  _add_new_label(_config_cleaned)

func error(msg):
  show({
    "text": msg,
    "bgcolor": Color(1, 0, 0, .4),
    "color": Color(1, 1, 1, 1),
    "gravity": "top",
    "direction": "right"
  })

func success(msg):
  show({
    "text": msg,
    "bgcolor": Color(0.0235294118, 1, 0, .3),
    "color": Color(1, 1, 1, 1),
    "gravity": "top",
    "direction": "right"
  })

func info(msg):
  show({
    "text": msg,
    "bgcolor": Color(0, 0.8941176471, 1, .2),
    "color": Color(1, 1, 1, 1),
    "gravity": "top",
    "direction": "right"
  })