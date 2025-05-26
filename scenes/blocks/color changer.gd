extends Sprite2D
func _ready() -> void:
  log.pp(global.currentLevelSettings("color"))
  texture = load(texture.resource_path.replace("1.png", str(global.currentLevelSettings("color")) + ".png"))
