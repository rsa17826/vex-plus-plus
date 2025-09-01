extends Node2D
class_name HitboxTypes

enum Types {
  attachDetector,
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
  match hitboxType:
    Types.attachDetector:
      visible = global.useropts.showAttachDetectorHitboxes
      self.debug_color = global.useropts.attachDetectorHitboxColor
    Types.solid:
      visible = global.useropts.showDeathHitboxes
      self.debug_color = global.useropts.solidHitboxColor
    Types.area:
      visible = global.useropts.showAreaHitboxes
      self.debug_color = global.useropts.areaHitboxColor
    Types.death:
      visible = global.useropts.showSolidHitboxes
      self.debug_color = global.useropts.deathHitboxColor
    # 0.4196078431