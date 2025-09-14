extends GridDisplay

@export var hasNums := false

func _ready() -> void:
  global.overlays.append(self)

func _process(delta: float) -> void:
  if global.showEditorUi:
    visible = global.useropts.showGridInEdit
    if !global.useropts.showGridInEdit: return
  else:
    visible = global.useropts.showGridInPlay
    if !global.useropts.showGridInPlay: return
  if global.useropts.blockGridSnapSize > 50:
    if hasNums:
      cell_size = Vector2(global.useropts.blockGridSnapSize, global.useropts.blockGridSnapSize)
    else:
      cell_size = Vector2(50, 50)
  else:
    if hasNums:
      cell_size = Vector2(50, 50)
    else:
      cell_size = Vector2(global.useropts.blockGridSnapSize, global.useropts.blockGridSnapSize)
  grid_size = Vector2(72.0, 40.0) * cell_size.x
  # if !global.player: return
  var mover = self
  var intendedPos = (global.player.get_node("Camera2D").get_screen_center_position() - get_viewport_rect().size / 2)
  mover.position = round((intendedPos) / cell_size.x) * cell_size.x
  # mover.position+=Vector2(576.0, 324.0)/2
  mover.position -= Vector2(200, 200)
  if hasNums:
    get_node("x").global_position.y = intendedPos.y - 50
    get_node("y").global_position.x = intendedPos.x + 120
    for i in range(1, 21):
      get_node("x/" + str(i)).text = str(int(round(((mover.position.x + 95 + 200) / cell_size.x)) + (i - 1)))
    for i in range(1, 14):
      get_node("y/" + str(i)).text = str(int(round(((mover.position.y + 480 + 200) / cell_size.x)) - (i - 3)))
    # log.pp(mover.position, intendedPos)