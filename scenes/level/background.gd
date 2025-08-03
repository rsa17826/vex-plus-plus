extends TextureRect

var modSize: Vector2

func _ready() -> void:
  if global.useropts.editorBackgroundTexture:
    var im = Image.new()
    im.load(global.useropts.editorBackgroundTexture)
    texture = ImageTexture.create_from_image(im)
    if not texture:
      log.error("Could not load background image from", global.useropts.editorBackgroundTexture)
      return
    modSize = texture.get_size()
    log.pp(modSize)

func _process(delta: float) -> void:
  if modSize:
    position = round((global.player.get_node("Camera2D").position - size / 2) / modSize) * modSize