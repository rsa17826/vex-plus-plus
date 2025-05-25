extends Sprite2D
func _ready() -> void:
  texture = load(texture.resource_path.replace("1.png", str(global.levelColor) + ".png"))
