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
    block.onOptionEdit = func() -> void:
      log.pp(block.selectedOptions)
      global.defaultBlockOpts[blockName] = block.selectedOptions
      sds.saveDataToFile("user://defaultBlockOpts.sds", global.defaultBlockOpts)
      await global.wait()
      block.queue_free.call_deferred()

    add_child(block)
    await global.wait()
    block.showPopupMenu()
    
func _on_mouse_exited() -> void:
  if self in global.hoveredBrushes:
    global.hoveredBrushes.erase(self )
  scale = normalScale
  z_index = 1
  selected = 0
