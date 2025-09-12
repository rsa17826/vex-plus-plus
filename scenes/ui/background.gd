extends TextureRect

func _ready():
  if global.useropts.editorBackgroundPath:
    var im = Image.new()
    im.load(global.useropts.editorBackgroundPath)
    texture = ImageTexture.create_from_image(im)
    if not texture:
      log.error("Could not load background image from", global.useropts.editorBackgroundPath)
      return
    stretch_mode = StretchMode.STRETCH_KEEP_ASPECT_CENTERED \
    if global.useropts.editorBackgroundScaleToMaxSize \
    else StretchMode.STRETCH_KEEP_CENTERED

func _process(delta):
  if global.hideAllOverlays:
    visible = false
    return
  visible = true