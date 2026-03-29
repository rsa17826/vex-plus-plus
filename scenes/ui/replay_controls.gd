# res://scenes/ui/replay_controls.gd
extends Control

var _slider: HSlider
var _play_pause_btn: Button
var _frame_label: Label
var _scrubbing: bool = false
var _seek_to: int = -1  # -1 = idle. >=0 = run real frames until Replay.frame reaches this

func _ready() -> void:
  _build_ui()
  set_process(true)
  set_physics_process(true)

func _physics_process(_delta: float) -> void:
  # When seeking: let real physics frames run and stop once we hit the target.
  # This is the only correct way to advance the replay — move_and_slide needs
  # a real physics tick, not a manual _physics_process call.
  if _seek_to >= 0 and global.Replay.frame >= _seek_to:
    _seek_to = -1
    global.Replay.pause()

func _build_ui() -> void:
  var bg := ColorRect.new()
  bg.color = Color(0, 0, 0, 0.72)
  bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
  add_child(bg)

  var margin := MarginContainer.new()
  margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  margin.add_theme_constant_override("margin_left",  12)
  margin.add_theme_constant_override("margin_right", 12)
  margin.add_theme_constant_override("margin_top",    6)
  margin.add_theme_constant_override("margin_bottom", 6)
  add_child(margin)

  var hbox := HBoxContainer.new()
  hbox.add_theme_constant_override("separation", 6)
  hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
  margin.add_child(hbox)

  _play_pause_btn = _btn("▶", _on_play_pause)
  _play_pause_btn.custom_minimum_size = Vector2(44, 0)
  hbox.add_child(_play_pause_btn)

  hbox.add_child(_btn("◀|", func(): _step(-1)))
  hbox.add_child(_btn("|▶", func(): _step(1)))

  _slider = HSlider.new()
  _slider.min_value = 0
  _slider.step = 1
  _slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  _slider.size_flags_vertical   = Control.SIZE_SHRINK_CENTER
  _slider.focus_mode = Control.FOCUS_NONE
  _slider.drag_started.connect(func():
    _scrubbing = true
    global.Replay.pause())
  _slider.drag_ended.connect(func(_changed):
    _scrubbing = false
    _seek(int(_slider.value)))
  hbox.add_child(_slider)

  _frame_label = Label.new()
  _frame_label.custom_minimum_size = Vector2(110, 0)
  _frame_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
  _frame_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
  hbox.add_child(_frame_label)

func _process(_delta: float) -> void:
  if not is_instance_valid(global.player): return
  visible = global.Replay.playing

  if not visible: return

  var total: int = global.Replay.totalFrames()
  var frame: int = global.Replay.frame

  if _slider.max_value != total:
    _slider.max_value = total
  if not _scrubbing:
    _slider.set_value_no_signal(frame)

  _play_pause_btn.text = "⏸" if (global.Replay.playing and not global.Replay.paused) else "▶"

  var fps  := Engine.physics_ticks_per_second
  var secs := frame / float(fps) if fps > 0 else 0.0
  _frame_label.text = "%d / %d  (%.1f s)" % [frame, total, secs]

func _on_play_pause() -> void:
  if not is_instance_valid(global.player): return
  _seek_to = -1  # cancel any in-progress seek
  if not global.Replay.playing:
    if global.Replay.data.is_empty(): return
    if global.Replay.frame >= global.Replay.totalFrames():
      global.Replay.frame = 0
    global.Replay.playing = true
    global.Replay.paused = false
  elif global.Replay.paused:
    global.Replay.resume()
  else:
    global.Replay.pause()

# ── Shared seek: restore nearest snapshot then run real frames to target ──────
func _seek(target: int) -> void:
  if not is_instance_valid(global.player): return
  target = clampi(target, 0, global.Replay.totalFrames())
  global.Replay.seek(target)   # restores snapshot, sets Replay.frame = best snapshot frame
  if global.Replay.frame >= target:
    # Already at or past target (target was exactly on a snapshot)
    global.Replay.pause()
    _seek_to = -1
  else:
    # Let real physics frames run until we reach the target
    _seek_to = target
    global.Replay.paused = false

func _step(frames: int) -> void:
  if not is_instance_valid(global.player): return
  _seek(global.Replay.frame + frames)

func _btn(label: String, cb: Callable) -> Button:
  var b := Button.new()
  b.text = label
  b.focus_mode = Control.FOCUS_NONE
  b.pressed.connect(cb)
  return b