extends Sprite2D
func _ready() -> void:
  # log.pp(global.currentLevelSettings("color"), texture.resource_path.replace("1.png", +".png"))
  texture = load(global.regReplace(texture.resource_path, '/[^/]+$', '/' + str(global.currentLevelSettings("color")) + '.png'))
