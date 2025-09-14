extends TextureRect

func _ready():
  global.overlays.append(self)
  if global.useropts.editorStickerPath:
    var im = Image.new()
    im.load(global.useropts.editorStickerPath)
    texture = ImageTexture.create_from_image(im)
    if not texture:
      log.error("Could not load sticker image from", global.useropts.editorStickerPath)
      return
    position -= (im.get_size() as Vector2) / 2.0