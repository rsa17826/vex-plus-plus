class_name SplitScreen
extends Control
## shows one view of the level per player when there is more than one player and the editor isn't open.
## all views share the world of the main viewport, so only the cameras differ.
## while editing the views are hidden and the main viewport follows global.focusedPlayer

var grid: GridContainer
var views: Dictionary[Player, SubViewportContainer] = {}

func _ready() -> void:
  global.splitScreen = self
  mouse_filter = Control.MOUSE_FILTER_IGNORE
  var background := ColorRect.new()
  background.color = Color.BLACK
  background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  background.mouse_filter = Control.MOUSE_FILTER_IGNORE
  add_child(background)
  grid = GridContainer.new()
  grid.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
  grid.add_theme_constant_override("h_separation", 2)
  grid.add_theme_constant_override("v_separation", 2)
  add_child(grid)
  global.playersChanged.connect(rebuild)
  global.onEditorStateChanged.connect(updateVisibility)
  rebuild()

func _exit_tree() -> void:
  if global.splitScreen == self:
    global.splitScreen = null

func rebuild() -> void:
  for p in views.keys():
    if p not in global.players:
      views[p].queue_free()
      views.erase(p)
  for p: Player in global.players:
    if p in views: continue
    var container := SubViewportContainer.new()
    container.stretch = true
    container.mouse_filter = Control.MOUSE_FILTER_IGNORE
    container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    container.size_flags_vertical = Control.SIZE_EXPAND_FILL
    var vp := SubViewport.new()
    vp.world_2d = get_viewport().world_2d
    vp.disable_3d = true
    vp.handle_input_locally = false
    vp.gui_disable_input = true
    vp.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
    container.add_child(vp)
    # the ui's background image is a canvas layer of the main viewport, so every view needs its own copy
    var bgLayer := CanvasLayer.new()
    bgLayer.layer = -1
    bgLayer.add_child(global.ui.get_node("-1 - background/background").duplicate())
    vp.add_child(bgLayer)
    var cam := PlayerViewCamera.new()
    cam.player = p
    vp.add_child(cam)
    grid.add_child(container)
    views[p] = container
  # keep the views in player order
  for i in len(global.players):
    grid.move_child(views[global.players[i]], i)
  grid.columns = maxi(1, ceili(sqrt(len(global.players))))
  updateVisibility()
func _process(_delta: float) -> void:
  # a Control directly under a CanvasLayer doesn't get a size from its anchors, so size it to the viewport
  if size != get_viewport_rect().size:
    size = get_viewport_rect().size
  var shouldShow := global.isMultiplayer() and not global.showEditorUi
  if shouldShow != visible:
    updateVisibility()

func updateVisibility() -> void:
  visible = global.isMultiplayer() and not global.showEditorUi
  for p in views:
    var vp: SubViewport = views[p].get_child(0)
    vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS if visible else SubViewport.UPDATE_DISABLED

## the player whose view is under the mouse, or if the mouse is in a gap the closest view
func playerUnderMouse() -> Player:
  var mouse := get_viewport().get_mouse_position()
  var best: Player
  var bestDist := INF
  for p in views:
    var rect := views[p].get_global_rect()
    if rect.has_point(mouse): return p
    var dist := rect.get_center().distance_to(mouse)
    if dist < bestDist:
      bestDist = dist
      best = p
  assert(best, "split screen has no views")
  return best

func worldMousePosition(p: Player) -> Vector2:
  var container := views[p]
  var vp: SubViewport = container.get_child(0)
  var local := get_viewport().get_mouse_position() - container.global_position
  return vp.get_canvas_transform().affine_inverse() * local
