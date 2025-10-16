extends Sprite2D
func _ready() -> void:
  if !global.player: return
  # log.pp(global.currentLevelSettings("color"), texture.resource_path.replace("1.png", +".png"))
  texture = load(texture.resource_path.replace("1.png", str(global.currentLevelSettings("color")) + '.png'))
