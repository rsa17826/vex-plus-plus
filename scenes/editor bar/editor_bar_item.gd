extends Area2D
# @name same line return
# @regex :\s*return\s*$
# @replace : return
# @flags gm
# @endregex

var id: int = 0
var normalScale = Vector2.ZERO
var selected = 0
var blockName := ''

func _init() -> void:
  if !global.lastSelectedBrush or !is_instance_valid(global.lastSelectedBrush):
    global.lastSelectedBrush = self

func _on_mouse_entered() -> void:
  scale = normalScale * 1.1
  z_index = 2
  selected = 1

func _input(event: InputEvent) -> void:
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

    add_child(block)
    await global.wait()
    block.showPopupMenu()
    await global.wait()
    log.pp(block.selectedOptions)
    global.defaultBlockOpts[blockName] = block.selectedOptions
    sds.saveDataToFile("user://defaultBlockOpts.sds", global.defaultBlockOpts)
    block.queue_free.call_deferred()
    
func _on_mouse_exited() -> void:
  scale = normalScale
  z_index = 1
  selected = 0
