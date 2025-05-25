extends VBoxContainer

var options = []
var selected = []

signal option_changed
@onready var main_cloner = $cloneContainer/CenterContainer

func _ready() -> void:
  for option in options:
    var clone = main_cloner.duplicate()
    clone.visible = true
    clone.get_node("cloner/CheckBox").button_pressed = option in selected
    clone.get_node("cloner/Label").text = option
    # clone.get_node("CheckBox").idx = options.find(option)
    clone.get_node("cloner/CheckBox").toggled.connect(_on_check_box_toggled.bind(option))
    $cloneContainer.add_child(clone)
  main_cloner.queue_free()
  
func _on_option_button_pressed() -> void:
  $cloneContainer.visible = !$cloneContainer.visible

func _on_check_box_toggled(toggled_on: bool, option) -> void:
  if toggled_on:
    selected.append(option)
  else:
    selected.erase(option)
  option_changed.emit()
