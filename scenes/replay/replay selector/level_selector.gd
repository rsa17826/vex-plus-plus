extends Control

const REPLAY_ROOT := "res://replays"

@export var _scroll: ScrollContainer
@export var _list: VBoxContainer
@export var _close_btn: Button

func _ready() -> void:
  _close_btn.pressed.connect(_on_close)
  _build_list()

func _build_list() -> void:
  for child in _list.get_children():
    child.queue_free()

  var dir := DirAccess.open(REPLAY_ROOT)
  if not dir:
    _show_empty()
    return

  var level_names: Array = []
  dir.list_dir_begin()
  var entry := dir.get_next()
  while entry != "":
    if dir.current_is_dir() and not entry.begins_with("."):
      level_names.append(entry)
    entry = dir.get_next()
  dir.list_dir_end()
  level_names.sort()

  if level_names.is_empty():
    _show_empty()
    return

  for level_name:String in level_names:
    var level_path := REPLAY_ROOT + "/" + level_name

    # Level header
    var header := Label.new()
    header.text = level_name
    header.add_theme_font_size_override("font_size", 16)
    header.add_theme_color_override("font_color", Color(1, 1, 1))
    _list.add_child(header)
    _list.add_child(HSeparator.new())

    # Replay entries inside this level folder
    var sub_dir := DirAccess.open(level_path)
    if not sub_dir: continue

    var replay_ids: Array = []
    sub_dir.list_dir_begin()
    var r := sub_dir.get_next()
    while r != "":
      if not sub_dir.current_is_dir() and not r.begins_with("."):
        replay_ids.append(r)
      r = sub_dir.get_next()
    sub_dir.list_dir_end()
    replay_ids.sort()

    for replay_id:String in replay_ids:
      var replay_path := level_path + "/" + replay_id
      _list.add_child(_make_row(level_name, replay_id, replay_path))

    var spacer := Control.new()
    spacer.custom_minimum_size = Vector2(0, 8)
    _list.add_child(spacer)

func _show_empty() -> void:
  var lbl := Label.new()
  lbl.text = "No replays found."
  lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
  _list.add_child(lbl)

func _make_row(level_name: String, replay_id: String, replay_path: String) -> HBoxContainer:
  var row := HBoxContainer.new()
  row.add_theme_constant_override("separation", 8)

  var lbl := Label.new()
  lbl.text = "  Replay " + replay_id
  lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  lbl.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))

  var play_btn := Button.new()
  play_btn.text = "Play"
  play_btn.pressed.connect(_play_replay.bind(replay_path))

  var delete_btn := Button.new()
  delete_btn.text = "Delete"
  delete_btn.pressed.connect(_delete_replay.bind(replay_path, level_name))

  row.add_child(lbl)
  row.add_child(play_btn)
  row.add_child(delete_btn)
  return row

func _play_replay(replay_path: String) -> void:
  visible = false
  await global.Replay.loadReplay(replay_path)
  global.Replay.startPlayback()
  await global.waituntil(func(): return not global.Replay.playing)
  visible = true
  _build_list()

func _delete_replay(replay_path: String, level_name: String) -> void:
  var confirmed = await global.prompt("Delete this replay?", global.PromptTypes.confirm)
  if not confirmed: return
  DirAccess.remove_absolute(ProjectSettings.globalize_path(replay_path))
  # Remove the level folder too if it is now empty
  var level_path := REPLAY_ROOT + "/" + level_name
  var d := DirAccess.open(level_path)
  if d:
    d.list_dir_begin()
    var remaining := d.get_next()
    d.list_dir_end()
    if remaining == "":
      DirAccess.remove_absolute(ProjectSettings.globalize_path(level_path))
  _build_list()

func _on_close() -> void:
  visible = false