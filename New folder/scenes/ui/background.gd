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

# func _process(delta):
#   global_position = (global.player.get_node("Camera2D") as Camera2D).global_position - Vector2(1152.0, 648.0) / 2