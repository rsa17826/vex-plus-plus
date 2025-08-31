extends "res://scenes/tab menu/group.gd"

func _on_attach_detector_toggled(toggled_on: bool) -> void:
  global.hitboxTypes.attachDetector = toggled_on
  global.hitboxTypesChanged.emit()

func _on_death_toggled(toggled_on: bool) -> void:
  global.hitboxTypes.death = toggled_on
  global.hitboxTypesChanged.emit()

func _on_area_toggled(toggled_on: bool) -> void:
  global.hitboxTypes.area = toggled_on
  global.hitboxTypesChanged.emit()

func _on_solid_toggled(toggled_on: bool) -> void:
  global.hitboxTypes.solid = toggled_on
  global.hitboxTypesChanged.emit()

func _ready() -> void:
  $_/attachDetector/attachDetector.button_pressed = global.hitboxTypes.attachDetector
  $_/death/death.button_pressed = global.hitboxTypes.death
  $_/area/area.button_pressed = global.hitboxTypes.area
  $_/solid/solid.button_pressed = global.hitboxTypes.solid