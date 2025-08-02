extends Control

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
  clearItems()
  await global.wait()
  for k: String in block.blockOptions:
    var node
    if global.same(blockOptions[k].type, 'BUTTON'):
      node = menuNodes[blockOptions[k].type].duplicate()
      node.text = k
      node.pressed.connect(onThingChanged.bind(k, node))
      var nameNode = $base/label.duplicate()
      nameNode.custom_minimum_size = node.size + Vector2(0, 2)
      nameNode.size = node.size + Vector2(0, 2)
      nameNode.text = ''
      $outputContainer.add_child(nameNode)
    else:
      node = menuNodes[blockOptions[k].type].duplicate()
      var nameNode = $base/label.duplicate()
      nameNode.text = k + ": " + global.PromptTypes.keys()[blockOptions[k].type].replace("_", '')
      nameNode.custom_minimum_size = node.size + Vector2(0, 2)
      nameNode.size = node.size + Vector2(0, 2)
      $outputContainer.add_child(nameNode)
      match blockOptions[k].type:
        global.PromptTypes.bool:
          node.toggled.connect(onThingChanged.bind(k, node))
        global.PromptTypes.int:
          node.value_changed.connect(onThingChanged.bind(k, node))
        global.PromptTypes.float:
          node.value_changed.connect(onThingChanged.bind(k, node))
        global.PromptTypes.string:
          node.text_changed.connect(onThingChanged.bind(k, node))
        global.PromptTypes.rgb:
          node.color_changed.connect(onThingChanged.bind(k, node))
        global.PromptTypes.rgba:
          node.color_changed.connect(onThingChanged.bind(k, node))
        global.PromptTypes._enum:
          node.item_selected.connect(onThingChanged.bind(k, node))
        _:
          log.pp(k, "Unknown type: ", blockOptions[k].type)
    $outputContainer.add_child(node)
    var resetNode = $base/reset.duplicate()
    resetNode.pressed.connect(onThingReset.bind(k, node))
    $outputContainer.add_child(resetNode)
  updateBlockMenuValues()

func clearItems():
  for child in $outputContainer.get_children():
    child.queue_free()

func updateBlockMenuValues() -> void:
  var block = global.lastSelectedBlock
  if block != lastShownBlock:
    showBlockMenu()
    return
  var blockOptions = block.blockOptions
  var selectedOptions = block.selectedOptions
  var i := -2
  for k: String in block.blockOptions:
    var disabled: bool = !(
      'showIf' not in blockOptions[k]
      or blockOptions[k].showIf.call()
    )
    i += 3
    var val
    if blockOptions[k].type is global.PromptTypes:
      if blockOptions[k].type == global.PromptTypes._enum:
        val = blockOptions[k].values.find(selectedOptions[k]) \
        if blockOptions[k].values is Array else \
        blockOptions[k].values.keys()[selectedOptions[k]]
      else:
        val = selectedOptions[k]
      var node = $outputContainer.get_child(i)
      $outputContainer.get_child(i - 1).text = k + ": " + global.PromptTypes.keys()[blockOptions[k].type].replace("_", '')
      $outputContainer.get_child(i + 1).modulate.a = 0
      if 'default' in blockOptions[k] and !global.same(selectedOptions[k], blockOptions[k].default):
        $outputContainer.get_child(i + 1).modulate.a = 1
      match blockOptions[k].type:
        global.PromptTypes.bool:
          node.button_pressed = val
          node.disabled = disabled
        global.PromptTypes.int:
          node.value = val
          node.editable = !disabled
        global.PromptTypes.float:
          node.value = val
          node.disabled = disabled
        global.PromptTypes.string:
          node.text = val
          node.editable = !disabled
        global.PromptTypes.rgb:
          node.color = val
          node.disabled = disabled
        global.PromptTypes.rgba:
          node.color = val
          node.disabled = disabled
        global.PromptTypes._enum:
          var ob: OptionButton = node
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
      $outputContainer.get_child(i + 1).disabled = disabled
      node.visible = true

func onThingReset(...data) -> void:
  var node = data.pop_back()
  var k = data.pop_back()
  if !global.isAlive(global.lastSelectedBlock):
    clearItems()
    return

  var block = global.lastSelectedBlock
  var blockOptions = block.blockOptions
  var selectedOptions = block.selectedOptions

  var val = blockOptions[k].default
  if \
  'onChange' not in blockOptions[k] \
  or blockOptions[k].onChange.call(val):
    selectedOptions[k] = val
    block.toType(k)
  block.respawn()
  block._ready()
  block.onOptionEdit.call()
  updateBlockMenuValues()

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
        return node.button_pressed
      global.PromptTypes.int:
        return node.value
      global.PromptTypes.float:
        return node.value
      global.PromptTypes.string:
        return node.text
      global.PromptTypes.rgb:
        return node.color
      global.PromptTypes.rgba:
        return node.color
      global.PromptTypes._enum:
        return node.selected if blockOptions[k].values is Dictionary else blockOptions[k].values[node.selected]
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
  var control_rect = $outputContainer.get_rect()
  control_rect.position = Vector2.ZERO
  var local_rect = control_rect
  if local_rect.has_point(get_local_mouse_position()): return
  get_viewport().gui_release_focus()