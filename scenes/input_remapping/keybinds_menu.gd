class_name KeybindsMenu
extends Control
## grid based keybinds menu. actions are sorted into categories, every action is a card with its bindings,
## and the "CREATE NEW - <block>" actions show the block's editor bar icon.

const CREATE_NEW_PREFIX := "CREATE NEW - "
const CREATE_BLOCK_CATEGORY := "Create Block"
const OTHER_CATEGORY := "Other"
const MAX_BINDINGS := 4
const CARD_WIDTH := 190
const DEFAULT_BLOCK_ICON: Texture2D = preload("res://scenes/blocks/image.png")

## explicit categories, an action that isn't listed here ends up in "Other"
const CATEGORIES: Array[Dictionary] = [
  {"name": "Player", "actions": [
    &"jump", &"down", &"left", &"right", &"restart", &"full_restart",
    &"activate_temporary_checkpoint", &"toggle_noclip", &"exit_inner_level",
  ]},
  {"name": "Camera & View", "actions": [
    &"editor_pan", &"focus_on_player", &"toggle_hitboxes", &"toggle_hide_non_ghosts",
    &"toggle_block_id_viewer", &"toggle_fullscreen",
  ]},
  {"name": "Selecting & Editing", "actions": [
    &"editor_select", &"editor_box_select", &"editor_edit_special", &"editor_scale", &"editor_rotate",
    &"editor_delete", &"duplicate_block", &"editor_disable_grid_snap", &"invert_single_axis_align",
    &"lock_selected_block", &"move_player_to_mouse",
  ]},
  {"name": "Move & Arrange", "actions": [
    &"move_selected_left", &"move_selected_right", &"move_selected_up", &"move_selected_down",
    &"block_z_up", &"block_z_down",
  ]},
  {"name": "Copy & Paste", "actions": [
    &"copy_block_position", &"copy_block_scale", &"copy_block_rotation",
    &"paste_block_position", &"paste_block_scale", &"paste_block_rotation",
  ]},
  {"name": "Level", "actions": [
    &"save", &"edit_level_mods", &"reload_map_from_last_save", &"fully_reload_map",
    &"new_level_file", &"new_map_folder", &"open_online_levels_list", &"open_main_menu",
  ]},
  {"name": "Menus & Tools", "actions": [
    &"show_keybinds", &"toggle_tab_menu", &"toggle_pause", &"quit", &"focus_search",
    &"accept_autocomplete", &"eval_expr", &"copy_debug_info",
  ]},
]

## icons for actions that aren't blocks, action name -> image path. add more here.
const ACTION_ICONS: Dictionary = {
  &"focus_on_player": "res://scenes/player/images/anim/idle/1.png",
  &"toggle_noclip": "res://scenes/player/images/anim/idle/1.png",
  &"activate_temporary_checkpoint": "res://scenes/player/images/anim/idle/1.png",
  &"move_player_to_mouse": "res://scenes/player/images/anim/idle/1.png",
}

var _search: LineEdit
var _categoryList: VBoxContainer
var _content: VBoxContainer
var _categoryGroup := ButtonGroup.new()
var _selectedCategory := ""
## category name -> actions, rebuilt every time the menu opens
var _categoryActions: Dictionary[String, Array] = {}
var _categoryOrder: Array[String] = []
## the categories that are rows of the editor bar, they come after Create Block
var _barGroups: Array[String] = []
## action -> the block it creates (a block name or a custom block dictionary), for the icons
var _actionBlock: Dictionary[StringName, Variant] = {}
var _iconCache: Dictionary[String, Texture2D] = {}

var _promptDim: ColorRect
var _promptTitle: Label
var _promptKey: Label
var _promptBody: Label
var _promptButtons: HBoxContainer
var _promptPanel: PanelContainer

var _capturing := false
var _captureAction: StringName
var _captureSlot := 0

func _init() -> void:
  global.ctrlMenu = self

func _ready() -> void:
  # the window's theme is only set a couple of frames after startup, wait for it like the other menus do
  await global.wait()
  await global.wait()
  theme = get_window().theme
  _buildUi()
  if visible:
    _onVisibilityChanged()

func _buildUi() -> void:
  mouse_filter = Control.MOUSE_FILTER_STOP
  set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  var dim := ColorRect.new()
  dim.color = Color(0, 0, 0, 0.6)
  dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
  dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  add_child(dim)
  var panel := PanelContainer.new()
  panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 16)
  panel.add_theme_stylebox_override("panel", _panelStyle(8))
  add_child(panel)
  var root := VBoxContainer.new()
  root.add_theme_constant_override("separation", 6)
  panel.add_child(root)

  var header := HBoxContainer.new()
  header.add_theme_constant_override("separation", 6)
  root.add_child(header)
  var title := Label.new()
  title.text = "Keybinds"
  title.add_theme_font_size_override("font_size", 22)
  header.add_child(title)
  _search = LineEdit.new()
  _search.placeholder_text = "Search actions or keys..."
  _search.clear_button_enabled = true
  _search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  _search.text_changed.connect(func(_text: String) -> void: _refreshContent())
  header.add_child(_search)
  var reset := Button.new()
  reset.text = "Reset all"
  reset.pressed.connect(_askReset)
  header.add_child(reset)
  var closeButton := Button.new()
  closeButton.text = "Close"
  closeButton.pressed.connect(close)
  header.add_child(closeButton)

  var body := HBoxContainer.new()
  body.size_flags_vertical = Control.SIZE_EXPAND_FILL
  body.add_theme_constant_override("separation", 6)
  root.add_child(body)
  var sidebar := PanelContainer.new()
  sidebar.custom_minimum_size = Vector2(190, 0)
  sidebar.add_theme_stylebox_override("panel", _panelStyle(4))
  sidebar.self_modulate = Color(1.2, 1.2, 1.2)
  body.add_child(sidebar)
  var sidebarScroll := ScrollContainer.new()
  sidebarScroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
  sidebar.add_child(sidebarScroll)
  _categoryList = VBoxContainer.new()
  _categoryList.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  sidebarScroll.add_child(_categoryList)
  var contentScroll := ScrollContainer.new()
  contentScroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  contentScroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
  body.add_child(contentScroll)
  _content = VBoxContainer.new()
  _content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  _content.add_theme_constant_override("separation", 6)
  contentScroll.add_child(_content)

  var hint := Label.new()
  hint.text = "Click a key to change it, + to add another, x or right click to remove one."
  hint.modulate = Color(1, 1, 1, 0.6)
  root.add_child(hint)

  _buildPrompt()
  visibility_changed.connect(_onVisibilityChanged)

## the theme's own panel style with less padding, the card colors come from the theme like the other menus
func _panelStyle(margin: int) -> StyleBox:
  var style: StyleBox = get_theme_stylebox("panel", "PanelContainer").duplicate()
  style.set_content_margin_all(margin)
  return style

func _buildPrompt() -> void:
  _promptDim = ColorRect.new()
  _promptDim.color = Color(0, 0, 0, 0.55)
  _promptDim.mouse_filter = Control.MOUSE_FILTER_STOP
  _promptDim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  _promptDim.visible = false
  add_child(_promptDim)
  var center := CenterContainer.new()
  center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  _promptDim.add_child(center)
  _promptPanel = PanelContainer.new()
  _promptPanel.custom_minimum_size = Vector2(420, 0)
  _promptPanel.add_theme_stylebox_override("panel", _panelStyle(10))
  center.add_child(_promptPanel)
  var box := VBoxContainer.new()
  box.add_theme_constant_override("separation", 6)
  _promptPanel.add_child(box)
  _promptTitle = Label.new()
  _promptTitle.add_theme_font_size_override("font_size", 18)
  _promptTitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  _promptTitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
  box.add_child(_promptTitle)
  _promptKey = Label.new()
  _promptKey.add_theme_font_size_override("font_size", 28)
  _promptKey.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  box.add_child(_promptKey)
  _promptBody = Label.new()
  _promptBody.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  _promptBody.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
  box.add_child(_promptBody)
  _promptButtons = HBoxContainer.new()
  _promptButtons.alignment = BoxContainer.ALIGNMENT_CENTER
  _promptButtons.add_theme_constant_override("separation", 8)
  box.add_child(_promptButtons)

## buttons is an array of [text, callable], the prompt closes after any of them is pressed
func _showPrompt(title: String, key: String, body: String, buttons: Array) -> void:
  _promptTitle.text = title
  _promptKey.text = key
  _promptKey.visible = key != ""
  _promptBody.text = body
  _promptBody.visible = body != ""
  for child in _promptButtons.get_children():
    child.queue_free()
  for entry in buttons:
    var button := Button.new()
    button.text = entry[0]
    var callback: Callable = entry[1]
    button.pressed.connect(func() -> void:
      _hidePrompt()
      if callback.is_valid(): callback.call())
    _promptButtons.add_child(button)
  _promptDim.visible = true

func _hidePrompt() -> void:
  _capturing = false
  _promptDim.visible = false

func close() -> void:
  visible = false

func _onVisibilityChanged() -> void:
  if not visible:
    _hidePrompt()
    return
  _buildCategories()
  _refreshCategoryList()
  _refreshContent()

func _process(_delta: float) -> void:
  # a Control directly under a CanvasLayer doesn't get a size from its anchors
  if visible and size != get_viewport_rect().size:
    size = get_viewport_rect().size

func _input(event: InputEvent) -> void:
  if _capturing:
    _captureInput(event)
    return
  if event is InputEventKey:
    if Input.is_action_just_pressed("show_keybinds", true):
      visible = !visible

# ---------------- categories ----------------

func _actionName(action: StringName) -> String:
  if action.begins_with(CREATE_NEW_PREFIX):
    return action.trim_prefix(CREATE_NEW_PREFIX)
  return String(action).capitalize()

func _buildCategories() -> void:
  _categoryActions = {}
  _categoryOrder = []
  _barGroups = []
  _actionBlock = {}
  var all: Array[StringName] = AppSettings.get_action_names()
  var used: Array = []
  for category in CATEGORIES:
    var actions: Array = []
    for action: StringName in category.actions:
      if action in all:
        actions.append(action)
        used.append(action)
    if actions:
      _categoryActions[category.name] = actions
      _categoryOrder.append(category.name)
  # the create block actions, in the order of the editor bar
  var createActions: Array = []
  for block in global.blockNames:
    if not block: continue
    if global.same(block, &"SEPARATOR") or global.same(block, &"END_OF_LINE2"): continue
    var blockName: String = block.name if block is Dictionary else block
    var action := StringName(CREATE_NEW_PREFIX + blockName.replace("/", "_"))
    if action not in all or action in createActions: continue
    createActions.append(action)
    _actionBlock[action] = block
  # create block actions of blocks that aren't in the editor bar
  for action in all:
    if action.begins_with(CREATE_NEW_PREFIX) and action not in createActions:
      createActions.append(action)
      _actionBlock[action] = action.trim_prefix(CREATE_NEW_PREFIX)
  used.append_array(createActions)
  var others: Array = all.filter(func(action: StringName) -> bool: return action not in used)
  if others:
    _categoryActions[OTHER_CATEGORY] = others
    _categoryOrder.append(OTHER_CATEGORY)
  if createActions:
    _categoryActions[CREATE_BLOCK_CATEGORY] = createActions
    _categoryOrder.append(CREATE_BLOCK_CATEGORY)
  # one category per group of the editor bar file
  var barData: Dictionary = sds.loadDataFromFile(global.path.abs("res://editorBar.sds"), {})
  for groupName: String in barData:
    if groupName == "remove": continue
    var groupActions: Array = []
    for entry in barData[groupName]:
      var blockName: String = entry.name if entry is Dictionary else entry
      var action := StringName(CREATE_NEW_PREFIX + blockName.replace("/", "_"))
      if action not in all and blockName in global.oldNameMap:
        action = StringName(CREATE_NEW_PREFIX + String(global.oldNameMap[blockName]).replace("/", "_"))
      if action not in all or action in groupActions: continue
      groupActions.append(action)
      if action not in _actionBlock:
        _actionBlock[action] = entry
    if groupActions:
      _categoryActions[groupName] = groupActions
      _categoryOrder.append(groupName)
      _barGroups.append(groupName)
  if _selectedCategory not in _categoryOrder:
    _selectedCategory = _categoryOrder[0]

func _refreshCategoryList() -> void:
  for child in _categoryList.get_children():
    child.queue_free()
  var addedGroupsHeader := false
  for categoryName in _categoryOrder:
    if categoryName in _barGroups and not addedGroupsHeader:
      addedGroupsHeader = true
      var groupsHeader := Label.new()
      groupsHeader.text = "Editor bar rows"
      groupsHeader.modulate = Color(1, 1, 1, 0.6)
      _categoryList.add_child(groupsHeader)
    var button := Button.new()
    button.text = "%s  (%d)" % [categoryName, len(_categoryActions[categoryName])]
    button.toggle_mode = true
    button.button_group = _categoryGroup
    button.alignment = HORIZONTAL_ALIGNMENT_LEFT
    button.button_pressed = categoryName == _selectedCategory
    button.pressed.connect(func() -> void:
      _selectedCategory = categoryName
      _search.text = ""
      _refreshContent())
    _categoryList.add_child(button)

# ---------------- cards ----------------

func _matchesSearch(action: StringName, categoryName: String, query: String) -> bool:
  if _actionName(action).to_lower().contains(query): return true
  if categoryName.to_lower().contains(query): return true
  for event in InputMap.action_get_events(action):
    if InputEventHelper.get_text(event).to_lower().contains(query): return true
  return false

func _refreshContent() -> void:
  for child in _content.get_children():
    child.queue_free()
  var query := _search.text.strip_edges().to_lower()
  for categoryName in _categoryOrder:
    if not query and categoryName != _selectedCategory: continue
    # the editor bar rows only repeat what Create Block already has
    if query and categoryName in _barGroups: continue
    var actions: Array = _categoryActions[categoryName]
    if query:
      actions = actions.filter(func(action: StringName) -> bool: return _matchesSearch(action, categoryName, query))
    if not actions: continue
    var header := Label.new()
    header.text = categoryName
    header.add_theme_font_size_override("font_size", 18)
    _content.add_child(header)
    var flow := HFlowContainer.new()
    flow.add_theme_constant_override("h_separation", 4)
    flow.add_theme_constant_override("v_separation", 4)
    _content.add_child(flow)
    for action: StringName in actions:
      flow.add_child(_makeCard(action))

func _makeCard(action: StringName) -> Control:
  var card := PanelContainer.new()
  card.custom_minimum_size = Vector2(CARD_WIDTH, 0)
  card.add_theme_stylebox_override("panel", _panelStyle(4))
  card.self_modulate = Color(1.2, 1.2, 1.2)
  var row := HBoxContainer.new()
  row.add_theme_constant_override("separation", 6)
  card.add_child(row)
  var icon := _iconFor(action)
  if icon:
    var image := TextureRect.new()
    image.texture = icon
    image.custom_minimum_size = Vector2(36, 36)
    image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    image.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    row.add_child(image)
  var column := VBoxContainer.new()
  column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  column.add_theme_constant_override("separation", 2)
  row.add_child(column)
  var nameLabel := Label.new()
  nameLabel.text = _actionName(action)
  nameLabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
  nameLabel.custom_minimum_size = Vector2(110, 0)
  column.add_child(nameLabel)
  var events := InputMap.action_get_events(action)
  var canRemove: bool = len(events) > 1 or action.begins_with(CREATE_NEW_PREFIX)
  for i in len(events):
    var slot := HBoxContainer.new()
    slot.add_theme_constant_override("separation", 2)
    column.add_child(slot)
    var keyButton := Button.new()
    keyButton.text = InputEventHelper.get_text(events[i])
    keyButton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    keyButton.clip_text = true
    keyButton.tooltip_text = "Click to change, right click to remove"
    keyButton.pressed.connect(_beginCapture.bind(action, i))
    keyButton.gui_input.connect(func(inputEvent: InputEvent) -> void:
      if inputEvent is InputEventMouseButton and inputEvent.pressed and inputEvent.button_index == MOUSE_BUTTON_RIGHT:
        if canRemove: _removeBinding(action, i))
    slot.add_child(keyButton)
    var removeButton := Button.new()
    removeButton.text = "x"
    removeButton.disabled = not canRemove
    removeButton.tooltip_text = "Remove" if canRemove else "An action needs at least one key, assign a new one to replace it"
    removeButton.pressed.connect(_removeBinding.bind(action, i))
    slot.add_child(removeButton)
  if len(events) < MAX_BINDINGS:
    var addButton := Button.new()
    addButton.text = "+" if events else "+ assign key"
    addButton.tooltip_text = "Add a key"
    addButton.pressed.connect(_beginCapture.bind(action, len(events)))
    column.add_child(addButton)
  return card

func _iconFor(action: StringName) -> Texture2D:
  if action in ACTION_ICONS:
    return _loadImage(ACTION_ICONS[action])
  if action in _actionBlock:
    return _blockIcon(_actionBlock[action])
  return null

func _loadImage(path: String) -> Texture2D:
  if path in _iconCache: return _iconCache[path]
  var texture: Texture2D = load(path)
  _iconCache[path] = texture
  return texture

## the same icon the editor bar uses for the block, read from the scene file without creating the block
func _blockIcon(block: Variant) -> Texture2D:
  if block is Dictionary:
    var key: String = "custom:" + block.imagePath
    if key in _iconCache: return _iconCache[key]
    var image := Image.new()
    image.load(block.imagePath)
    var texture: Texture2D = DEFAULT_BLOCK_ICON if image.is_empty() else ImageTexture.create_from_image(image)
    _iconCache[key] = texture
    return texture
  var scenePath := "res://scenes/blocks/%s/main.tscn" % block
  if scenePath in _iconCache: return _iconCache[scenePath]
  var texture: Texture2D = DEFAULT_BLOCK_ICON
  if ResourceLoader.exists(scenePath):
    var scene: PackedScene = load(scenePath)
    var state := scene.get_state()
    var found := false
    for i in state.get_node_property_count(0):
      if state.get_node_property_name(0, i) == &"editorBarIcon":
        texture = state.get_node_property_value(0, i)
        found = true
        break
    if not found:
      # the icon is set by a scene this block inherits from
      var clone := scene.instantiate()
      texture = clone.editorBarIcon
      clone.queue_free()
  _iconCache[scenePath] = texture
  return texture

# ---------------- changing bindings ----------------

func _beginCapture(action: StringName, slot: int) -> void:
  _capturing = true
  _captureAction = action
  _captureSlot = slot
  _showPrompt(
    "Press a key or mouse button for\n" + _actionName(action),
    "...",
    "Modifier keys on their own are recorded when released.",
    [["Cancel", Callable()]],
  )

func _captureInput(event: InputEvent) -> void:
  var recorded: InputEvent
  if event is InputEventKey:
    if event.echo: return
    var isModifier: bool = event.physical_keycode in [KEY_CTRL, KEY_ALT, KEY_SHIFT, KEY_META]
    if isModifier:
      # a modifier on its own is recorded when it's released
      if event.pressed: return
    elif not event.pressed: return
    var key := InputEventKey.new()
    key.physical_keycode = event.physical_keycode
    key.shift_pressed = event.shift_pressed
    key.ctrl_pressed = event.ctrl_pressed
    key.alt_pressed = event.alt_pressed
    key.meta_pressed = event.meta_pressed
    recorded = key
  elif event is InputEventMouseButton:
    if not event.pressed: return
    # clicks on the prompt's own buttons are not bindings
    if _promptPanel.get_global_rect().has_point(event.position): return
    var mouse := InputEventMouseButton.new()
    mouse.button_index = event.button_index
    mouse.shift_pressed = event.shift_pressed
    mouse.ctrl_pressed = event.ctrl_pressed
    mouse.alt_pressed = event.alt_pressed
    mouse.meta_pressed = event.meta_pressed
    recorded = mouse
  elif event is InputEventJoypadButton:
    if not event.pressed: return
    var button := InputEventJoypadButton.new()
    button.button_index = event.button_index
    recorded = button
  else:
    return
  get_viewport().set_input_as_handled()
  _capturing = false
  _assign(_captureAction, _captureSlot, recorded)

## the action and slot that already has this input, or an empty action if nobody does
func _findOwner(recorded: InputEvent) -> Dictionary:
  var text := InputEventHelper.get_text(recorded)
  for action in AppSettings.get_action_names():
    var events := InputMap.action_get_events(action)
    for i in len(events):
      if InputEventHelper.get_text(events[i]) == text:
        return {"action": action, "slot": i}
  return {}

func _assign(action: StringName, slot: int, recorded: InputEvent) -> void:
  var text := InputEventHelper.get_text(recorded)
  var holder := _findOwner(recorded)
  if not holder:
    _applyBinding(action, slot, recorded)
    return
  var ownerAction: StringName = holder.action
  if ownerAction == action:
    if holder.slot == slot:
      _hidePrompt()
    else:
      _showPrompt("Already used", text, _actionName(action) + " already has this key.", [["OK", Callable()]])
    return
  var ownerCanLose: bool = len(InputMap.action_get_events(ownerAction)) > 1 or ownerAction.begins_with(CREATE_NEW_PREFIX)
  var buttons: Array = []
  if ownerCanLose:
    buttons.append(["Move it here", func() -> void:
      _removeBindingQuiet(ownerAction, holder.slot)
      _applyBinding(action, slot, recorded)])
  buttons.append(["Use for both", func() -> void: _applyBinding(action, slot, recorded)])
  buttons.append(["Cancel", Callable()])
  _showPrompt(
    "Already used",
    text,
    "%s is already assigned to %s." % [text, _actionName(ownerAction)],
    buttons,
  )

func _applyBinding(action: StringName, slot: int, recorded: InputEvent) -> void:
  var events := InputMap.action_get_events(action)
  if slot < len(events):
    events[slot] = recorded
  else:
    events.append(recorded)
  _setEvents(action, events)
  _hidePrompt()
  _refreshContent()

func _removeBinding(action: StringName, slot: int) -> void:
  _removeBindingQuiet(action, slot)
  _refreshContent()

func _removeBindingQuiet(action: StringName, slot: int) -> void:
  var events := InputMap.action_get_events(action)
  events.remove_at(slot)
  _setEvents(action, events)

func _setEvents(action: StringName, events: Array[InputEvent]) -> void:
  InputMap.action_erase_events(action)
  for event in events:
    InputMap.action_add_event(action, event)
  AppSettings.set_config_input_events(action, events)

func _askReset() -> void:
  _showPrompt(
    "Reset all keybinds?",
    "",
    "Every key goes back to its default, keys you added to the create block actions are removed.",
    [["Reset", func() -> void:
      AppSettings.reset_to_default_inputs()
      _refreshContent()], ["Cancel", Callable()]],
  )
