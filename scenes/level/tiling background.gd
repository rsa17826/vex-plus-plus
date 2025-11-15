extends TextureRect

var modSize: Vector2

func _ready() -> void:
  global.overlays.append(self)
  if global.useropts.levelTilingBackgroundPath:
    var im = Image.new()
    im.load(global.useropts.levelTilingBackgroundPath)
    texture = ImageTexture.create_from_image(im)
    if not texture:
      log.error("Could not load tiling background image from", global.useropts.levelTilingBackgroundPath)
      return
    modSize = texture.get_size()
    log.pp(modSize)

func _process(delta: float) -> void:
  visible = true
  if modSize:
    position = round((global.player.camera.global_position - size / 2) / modSize) * modSize