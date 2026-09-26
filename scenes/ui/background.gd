extends TextureRect

func _ready():
  global.overlays.append(self)
  if global.useropts.editorBackgroundPath:
    if not global.backgroundTexture:
      var im = Image.new()
      im.load(global.useropts.editorBackgroundPath)
      global.backgroundTexture = ImageTexture.create_from_image(im)
    if not global.backgroundTexture:
      log.error("Could not load background image from", global.useropts.editorBackgroundPath)
      return
    texture = global.backgroundTexture
    stretch_mode = StretchMode.STRETCH_KEEP_ASPECT_CENTERED \
    if global.useropts.editorBackgroundScaleToMaxSize \
    else StretchMode.STRETCH_KEEP_CENTERED
