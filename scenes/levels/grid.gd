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
  var intendedPos = global.player.get_node("Camera2D").get_screen_center_position() - get_viewport_rect().size / 2
  global_position = round((intendedPos) / gridSize) * gridSize
  get_node("x").position.y = (intendedPos - global_position).y - 50
  get_node("y").position.x = (intendedPos - global_position).x + 120
  for i in range(1, 21):
    get_node("x/" + str(i)).text = str(int(round(((global_position.x + 95) / gridSize)) + (i - 1)))
  for i in range(1, 14):
    get_node("y/" + str(i)).text = str(int(round(((global_position.y + 480) / gridSize)) - (i - 3)))
