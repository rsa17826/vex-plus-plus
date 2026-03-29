# res://scenes/ui/replay_controls.gd
# Builds its own child nodes — no extra scene editing needed.
extends Control

var _slider: HSlider
var _play_pause_btn: Button
var _frame_label: Label
var _scrubbing: bool = false   # true while user drags slider (pause injection)

func _ready() -> void:
  _build_ui()
  set_process(true)

func _build_ui() -> void:
  # ── Semi-transparent background strip ────────────────────────────────────
  var bg := ColorRect.new()
  bg.color = Color(0, 0, 0, 0.72)
  bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
  add_child(bg)

  # ── Outer margin ─────────────────────────────────────────────────────────
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

  # ── Play / Pause ──────────────────────────────────────────────────────────
  _play_pause_btn = _btn("▶", _on_play_pause)
  _play_pause_btn.custom_minimum_size = Vector2(44, 0)
  hbox.add_child(_play_pause_btn)

  # ── Step −1 ───────────────────────────────────────────────────────────────
  hbox.add_child(_btn("◀|", func(): _step(-1)))

  # ── Step +1 ───────────────────────────────────────────────────────────────
  hbox.add_child(_btn("|▶", func(): _step(1)))

  # ── Seek slider ───────────────────────────────────────────────────────────
  _slider = HSlider.new()
  _slider.min_value = 0
  _slider.step = 1
  _slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  _slider.size_flags_vertical   = Control.SIZE_SHRINK_CENTER
  _slider.focus_mode = Control.FOCUS_NONE
  _slider.value_changed.connect(_on_slider_changed)
  _slider.drag_started.connect(func(): _scrubbing = true)
  _slider.drag_ended.connect(func(_changed): _scrubbing = false)
  hbox.add_child(_slider)

  # ── Frame label ───────────────────────────────────────────────────────────
  _frame_label = Label.new()
  _frame_label.custom_minimum_size = Vector2(110, 0)
  _frame_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
  _frame_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
  hbox.add_child(_frame_label)

# ── Per-frame update ──────────────────────────────────────────────────────────
func _process(_delta: float) -> void:
  var player: Player = global.player
  if not is_instance_valid(player): return

  var is_replay: bool = global.replayPlaying or global._replay_recording
  visible = is_replay

  if not is_replay: return

  var total: int  = global.replay_total_frames()
  var frame: int  = global._replay_frame

  # Update slider range without triggering value_changed
  if _slider.max_value != total:
    _slider.max_value = total

  if not _scrubbing:
    _slider.set_value_no_signal(frame)

  # Play/Pause icon
  if global.replayPlaying and not global._replay_paused:
    _play_pause_btn.text = "⏸"
  else:
    _play_pause_btn.text = "▶"

  # Frame counter  e.g. "1234 / 5678  (20.5 s)"
  var fps  := Engine.physics_ticks_per_second
  var secs := frame / float(fps) if fps > 0 else 0.0
  _frame_label.text = "%d / %d  (%.1f s)" % [frame, total, secs]

# ── Callbacks ────────────────────────────────────────────────────────────────
func _on_play_pause() -> void:
  var player: Player = global.player
  if not is_instance_valid(player): return

  if not global.replayPlaying:
    # Was paused / stopped — resume or start
    if global._replay_data.is_empty(): return
    if global._replay_frame >= global.replay_total_frames():
      global._replay_frame = 0
    global._replay_playing = true
  else:
    if global._replay_paused:
      global.replay_resume()
    else:
      global.replay_pause()

func _on_slider_changed(value: float) -> void:
  if not _scrubbing: return
  if not is_instance_valid(global.player): return
  # Pause playback while scrubbing, seek on every drag tick
  global.replay_pause()
  global.replay_seek(int(value))

func _step(frames: int) -> void:
  if not is_instance_valid(global.player): return
  global.replay_pause()
  global.replay_seek(clampi(global._replay_frame + frames, 0, global.replay_total_frames() - 1))

# ── Helper ────────────────────────────────────────────────────────────────────
func _btn(label: String, cb: Callable) -> Button:
  var b := Button.new()
  b.text = label
  b.focus_mode = Control.FOCUS_NONE
  b.pressed.connect(cb)
  return b
