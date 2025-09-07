extends Area2D

var id: int = 0
var normalScale = Vector2.ZERO
var selected = 0
var blockName := ''

func _init() -> void:
  if !global.lastSelectedBrush or !is_instance_valid(global.lastSelectedBrush):
    global.lastSelectedBrush = self

func _on_mouse_entered() -> void:
  if self not in global.hoveredBrushes:
    global.hoveredBrushes.append(self )
  scale = normalScale * 1.1
  z_index = 2
  selected = 1

func _input(event: InputEvent) -> void:
  if global.openMsgBoxCount: return
  if selected >= 1 and Input.is_action_just_pressed("editor_select"):
    global.selectedBrush = self
    selected = 2
    global.localProcess(0)
  if !Input.is_action_pressed("editor_select"):
    global.justPaintedBlock = null
    global.selectedBrush = null
  if selected == 1 and Input.is_action_just_pressed("editor_edit_special"):
    var block = load("res://scenes/blocks/" + blockName + "/main.tscn").instantiate()
    block.id = blockName

    var pm: PopupMenu = PopupMenu.new()
    var can := CanvasLayer.new()

    var onOptionEdit = func onOptionEdit() -> void:
      log.pp(block.selectedOptions)
      global.defaultBlockOpts[blockName] = block.selectedOptions
      sds.saveDataToFile("user://defaultBlockOpts.sds", global.defaultBlockOpts)
      await global.wait()
      block.queue_free.call_deferred()
      can.queue_free.call_deferred()

    var editOption = func editOption(idx):
      if idx >= len(block.blockOptions.keys()):
        onOptionEdit.call()
        return
      # log.pp("editing", idx, blockOptions)
      var k: String = block.blockOptions.keys()[idx]
      var newData: Variant
      if block.blockOptions[k].type is global.PromptTypes:
        newData = await global.prompt(
          k,
          block.blockOptions[k].type,
          block.selectedOptions[k],
          block.blockOptions[k].default,
          block.blockOptions[k].values if "values" in block.blockOptions[k] else []
        )
      elif block.blockOptions[k].type == 'BUTTON':
        onOptionEdit.call()
        return
      if \
      'onChange' not in block.blockOptions[k] \
      or block.blockOptions[k].onChange.call(block.selectedOptions[k]):
        block.selectedOptions[k] = newData
        block.toType(k)
      onOptionEdit.call()

    if global.popupStarted: return
    add_child(can)
    can.add_child(pm)
    pm.system_menu_id = NativeMenu.SystemMenus.DOCK_MENU_ID
    add_child(block)
    await global.wait()
    if global.popupStarted: return
    var i := 0
    for k: String in block.blockOptions:
      var val
      if block.blockOptions[k].type is global.PromptTypes:
        if block.blockOptions[k].type == global.PromptTypes._enum:
          val = block.blockOptions[k].values[block.selectedOptions[k]]
        else:
          val = block.selectedOptions[k]
        pm.add_item(k + ": " + global.PromptTypes.keys()[block.blockOptions[k].type].replace("_", '') + " = " + str(val), i)
      elif block.blockOptions[k].type == 'BUTTON':
        pm.add_item(k, i)
      pm.set_item_disabled(i,
        !(
          'showIf' not in block.blockOptions[k]
          or block.blockOptions[k].showIf.call()
        )
      )
      i += 1
    pm.add_item('cancel', i)
    pm.connect("index_pressed", editOption)
    global.popupStarted = true
    pm.popup(Rect2i(get_screen_transform() * get_local_mouse_position(), Vector2i.ZERO))
    await global.wait()
    global.popupStarted = false

func _on_mouse_exited() -> void:
  if self in global.hoveredBrushes:
    global.hoveredBrushes.erase(self )
  scale = normalScale
  z_index = 1
  selected = 0
