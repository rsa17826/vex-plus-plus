extends VBoxContainer

var lastShownBlock

func showBlockMenu():
  var menuNodes := {
    "BUTTON": $base/button,
    global.PromptTypes.bool: $base/bool,
    global.PromptTypes.float: $base/float,
    global.PromptTypes.int: $base/int,
    global.PromptTypes.rgba: $base/rgba,
    global.PromptTypes.rgb: $base/rgb,
    global.PromptTypes.string: $base/string,
    global.PromptTypes._enum: $base/enum,
  }
  var block = global.lastSelectedBlock
  lastShownBlock = block
  var blockOptions = block.blockOptions
  var selectedOptions = block.selectedOptions
  log.pp(block.selectedOptions, block.blockOptions)
  # var i := 0
  clearItems()
  await global.wait()
  for k: String in block.blockOptions:
    var node
    if global.same(blockOptions[k].type, 'BUTTON'):
      node = menuNodes[blockOptions[k].type].duplicate()
      node.get_node("Button").text = k
      node.get_node("Button").pressed.connect(onThingChanged.bind(k, node))
    else:
      node = menuNodes[blockOptions[k].type].duplicate()
      node.get_node("name").text = k + ": " + global.PromptTypes.keys()[blockOptions[k].type].replace("_", '')
      match blockOptions[k].type:
        global.PromptTypes.bool:
          node.get_node("CheckButton").toggled.connect(onThingChanged.bind(k, node))
        global.PromptTypes.int:
          node.get_node("SpinBox").value_changed.connect(onThingChanged.bind(k, node))
        global.PromptTypes.float:
          node.get_node("SpinBox").value_changed.connect(onThingChanged.bind(k, node))
        global.PromptTypes.string:
          node.get_node("LineEdit").text_changed.connect(onThingChanged.bind(k, node))
        global.PromptTypes.rgb:
          node.get_node("ColorPickerButton").color_changed.connect(onThingChanged.bind(k, node))
        global.PromptTypes.rgba:
          node.get_node("ColorPickerButton").color_changed.connect(onThingChanged.bind(k, node))

        global.PromptTypes._enum:
          var ob: OptionButton = node.get_node("OptionButton")
          ob.item_selected.connect(onThingChanged.bind(k, node))
        _:
          log.pp(k, "Unknown type: ", blockOptions[k].type)
    node.visible = true
    add_child(node)
  updateBlockMenuValues()

    # pm.set_item_disabled(i,
    #   !(
    #     'showIf' not in blockOptions[k]
    #     or blockOptions[k].showIf.call()
    #   )
    # )
    # i += 1
func clearItems():
  for child in get_children():
    if child.name == "base": continue
    child.queue_free()
func updateBlockMenuValues() -> void:
  var block = global.lastSelectedBlock
  if block != lastShownBlock:
    showBlockMenu()
    return
  var blockOptions = block.blockOptions
  var selectedOptions = block.selectedOptions
  var i := 0
  for k: String in block.blockOptions:
    var disabled: bool = !(
      'showIf' not in blockOptions[k]
      or blockOptions[k].showIf.call()
    )
    i += 1
    var val
    if blockOptions[k].type is global.PromptTypes:
      if blockOptions[k].type == global.PromptTypes._enum:
        val = blockOptions[k].values.find(selectedOptions[k]) \
        if blockOptions[k].values is Array else \
        blockOptions[k].values.keys()[selectedOptions[k]]
      else:
        val = selectedOptions[k]
      var node = get_child(i)
      node.get_node("name").text = k + ": " + global.PromptTypes.keys()[blockOptions[k].type].replace("_", '')
      match blockOptions[k].type:
        global.PromptTypes.bool:
          node.get_node("CheckButton").button_pressed = val
          node.get_node("CheckButton").disabled = disabled
        global.PromptTypes.int:
          node.get_node("SpinBox").value = val
          node.get_node("SpinBox").editable = !disabled
        global.PromptTypes.float:
          node.get_node("SpinBox").value = val
          node.get_node("SpinBox").disabled = disabled
        global.PromptTypes.string:
          node.get_node("LineEdit").text = val
          node.get_node("LineEdit").editable = !disabled
        global.PromptTypes.rgb:
          node.get_node("ColorPickerButton").color = val
          node.get_node("ColorPickerButton").disabled = disabled
        global.PromptTypes.rgba:
          node.get_node("ColorPickerButton").color = val
          node.get_node("ColorPickerButton").disabled = disabled
        global.PromptTypes._enum:
          var ob: OptionButton = node.get_node("OptionButton")
          ob.disabled = disabled
          ob.clear()
          for thing: String in blockOptions[k].values:
            ob.add_item(thing)
          log.pp(blockOptions[k].values, val)
          ob.select(
            blockOptions[k].values[val] if blockOptions[k].values is Dictionary else
            val
          )
        _:
          log.pp(k, "Unknown type: ", blockOptions[k].type)
      node.visible = true

func onThingChanged(...data) -> void:
  var node = data.pop_back()
  var k = data.pop_back()
  if !global.isAlive(global.lastSelectedBlock):
    clearItems()
    return
  var block = global.lastSelectedBlock
  var blockOptions = block.blockOptions
  var selectedOptions = block.selectedOptions
  log.pp(k, node, "changed")
  var val = (func():
    match blockOptions[k].type:
      global.PromptTypes.bool:
        return node.get_node("CheckButton").button_pressed
      global.PromptTypes.int:
        return node.get_node("SpinBox").value
      global.PromptTypes.float:
        return node.get_node("SpinBox").value
      global.PromptTypes.string:
        return node.get_node("LineEdit").text
      global.PromptTypes.rgb:
        return node.get_node("ColorPickerButton").color
      global.PromptTypes.rgba:
        return node.get_node("ColorPickerButton").color
      global.PromptTypes._enum:
        return node.get_node("OptionButton").selected if blockOptions[k].values is Dictionary else blockOptions[k].values[node.get_node("OptionButton").selected]
      'BUTTON':
        pass
      _:
        log.pp(k, "Unknown type: ", blockOptions[k].type)
    ).call()
  if blockOptions[k].type is global.PromptTypes:
    pass
  elif blockOptions[k].type == 'BUTTON':
    if blockOptions[k].onChange.call():
      block.respawn()
      block._ready()
    block.onOptionEdit.call()
    return
  else:
    log.err("unknown type", k, blockOptions[k])
    breakpoint
  if \
  'onChange' not in blockOptions[k] \
  or blockOptions[k].onChange.call(val):
    selectedOptions[k] = val
    block.toType(k)
  # log.pp(newData, "newData")
  # if !newData: return
  block.respawn()
  block._ready()
  block.onOptionEdit.call()
  updateBlockMenuValues()

func _input(event):
  if not event is InputEventMouseButton: return
  if not event.pressed: return
  var control_rect = self.get_rect()
  control_rect.position = Vector2.ZERO
  var local_rect = control_rect
  if local_rect.has_point(get_local_mouse_position()): return
  get_viewport().gui_release_focus()