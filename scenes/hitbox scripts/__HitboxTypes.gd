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
      visible = global.hitboxTypes.attachDetector
      self.debug_color = global.useropts.attachDetectorHitboxColor
    Types.solid:
      visible = global.hitboxTypes.solid
      self.debug_color = global.useropts.solidHitboxColor
    Types.area:
      visible = global.hitboxTypes.area
      self.debug_color = global.useropts.areaHitboxColor
    Types.death:
      visible = global.hitboxTypes.death
      self.debug_color = global.useropts.deathHitboxColor
    # 0.4196078431