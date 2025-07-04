extends GridDisplay
const gridSize = 50
func _process(delta: float) -> void:
  if global.showEditorUi:
    visible = global.useropts.showGridInEdit
    if !global.useropts.showGridInEdit: return
  else:
    visible = global.useropts.showGridInPlay
    if !global.useropts.showGridInPlay: return
  # if !global.player: return
  var intendedPos = (global.player.get_node("Camera2D") as Camera2D)\
  .get_target_position() - get_viewport_rect().size / 2
  global_position = (round((intendedPos) / gridSize) * gridSize)-intendedPos
  get_node("x").global_position.y = intendedPos.y - 50
  get_node("y").global_position.x = intendedPos.x + 120
  for i in range(1, 21):
    get_node("x/" + str(i)).text = str(int(round(((intendedPos.x + 95) / gridSize)) + (i - 1)))
  for i in range(1, 14):
    get_node("y/" + str(i)).text = str(int(round(((intendedPos.y + 480) / gridSize)) - (i - 3)))
  # log.pp(global_position, intendedPos)