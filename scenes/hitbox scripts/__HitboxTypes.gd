extends Node2D
class_name HitboxTypes

enum Types {
  attachDetector,
  solid,
  area,
  death
}

var hitboxType: Types

func _init():
  match hitboxType:
    Types.attachDetector:
      self.debug_color = Color('df57006b')
    Types.solid:
      self.debug_color = Color('0099b36b')
    Types.area:
      self.debug_color = Color(0, 0, 1)
    Types.death:
      self.debug_color = Color('ff00006b')