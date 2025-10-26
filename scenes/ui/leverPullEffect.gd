extends Sprite2D
enum color {
  blue = 0,
  red = 1,
  green = 2
}
const sprites = [
  preload(
    "res://scenes/ui/images/leverPullEffect1.png"
  ),
  preload(
    "res://scenes/ui/images/leverPullEffect2.png"
  ),
  preload(
    "res://scenes/ui/images/leverPullEffect3.png"
  )
]
var activating = 0
func activate(color):
  texture = sprites[color]
  position.y = 648
  activating = -1
func deactivate(color):
  texture = sprites[color]
  position.y = 0
  activating = 1
const SPEED = 30

func _process(delta: float) -> void:
  visible = activating
  if activating:
    position.y += activating * SPEED
    if activating == -1:
      if position.y < 0:
        activating = 0
      if position.y > 648:
        activating = 0
