@tool
extends Node2D
class_name HitboxTypes

enum Types {
  # attachDetector,
  solid,
  area,
  death
}

var hitboxType: Types:
  set(val):
    hitboxType = val
    updateColor()

func _ready() -> void:
  global.hitboxTypesChanged.connect(updateColor)
  updateColor()

func updateColor() -> void:
  visibility_layer = 1
  if Engine.is_editor_hint() and is_inside_tree():
    if not get_parent().visible and (get_parent() is Area2D or get_parent() is StaticBody2D or get_parent() is CharacterBody2D):
      get_parent().visible = true
  if Engine.is_editor_hint() and not global.useropts:
    global.useropts = sds.loadDataFromFile("user://main - EDITOR.sds")
  match hitboxType:
    # Types.attachDetector:
    #   visible = global.useropts.showAttachDetectorHitboxes
    #   self.debug_color = global.useropts.attachDetectorHitboxColor
    Types.solid:
      visible = global.useropts.showSolidHitboxes
      self.debug_color = global.useropts.solidHitboxColor
    Types.area:
      visible = global.useropts.showAreaHitboxes
      self.debug_color = global.useropts.areaHitboxColor
    Types.death:
      visible = global.useropts.showDeathHitboxes
      self.debug_color = global.useropts.deathHitboxColor
  if Engine.is_editor_hint():
    visible = false
    # 0.4196078431