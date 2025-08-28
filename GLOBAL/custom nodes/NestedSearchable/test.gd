extends Control

func _ready() -> void:
  for child in $HBoxContainer.get_children():
    child.updateSearch("main root2")
  for child in $HBoxContainer.get_children():
    child.updateSearch("main root")
  for child in $HBoxContainer.get_children():
    child.updateSearch("main root3")