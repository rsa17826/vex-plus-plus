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
  updateColor()

func updateColor() -> void:
  match hitboxType:
    Types.attachDetector:
      self.debug_color = Color('#df57006b')
    Types.solid:
      self.debug_color = Color('#0099b36b')
    Types.area:
      self.debug_color = Color('#00ff006b')
    Types.death:
      self.debug_color = Color('#ff00006b')
      # 0.4196078431