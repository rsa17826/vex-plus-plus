@tool
extends Node

# REM: don't call globals by name until onready

# tilemap
# file
# arr
# event

#

func _ready() -> void:
  if !InputMap.has_action("quit"): return
  # InputMap.load_from_project_settings()
  localReady()

func _process(delta: float) -> void:
  if openMsgBoxCount: return
  if timer.started:
    timer.time += delta
  for i: Array in wait_until_wait_list:
    if has_user_signal(i[0]) and i[1] && i[1].is_valid() && i[1].call():
      Signal(self , i[0]).emit()
      remove_user_signal(i[0])
  if !InputMap.has_action("quit"): return
  localProcess(delta)

var openMsgBoxCount: int = 0

var promptPromise: Promise
const windowSize = Vector2(1152, 648)

enum PromptTypes {
  int,
  confirm,
  string,
  float,
  info,
  _enum,
  # multiSelect,
  bool,
  rgb,
  rgba,
  multiLineString
}

func prompt(msg: String, type: PromptTypes = PromptTypes.info, startVal: Variant = null, default: Variant = null, singleArrValues: Variant = []) -> Variant:
  if openMsgBoxCount:
    while openMsgBoxCount:
      await wait(10)
  var lastMouseMode := Input.mouse_mode
  Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
  openMsgBoxCount += 1

  var promptCanvas := preload("res://GLOBAL/__prompt.tscn").instantiate()
  get_tree().root.add_child(promptCanvas)
  promptCanvas.get_node("ColorRect").size = windowSize
  promptCanvas.get_node("ColorRect/CenterContainer").size = windowSize
  promptCanvas.promptText.text = msg

  promptCanvas.numEdit.visible = false
  promptCanvas.strEdit.visible = false
  promptCanvas.enumEdit.visible = false
  promptCanvas.colEdit.visible = false
  promptCanvas.textEdit.visible = false
  # log.pp(type)
  promptCanvas.btnCancel.text = "cancel"
  promptCanvas.btnOk.text = "ok"
  promptCanvas.btnCancel.visible = true
  if same(default, null) or same(default, startVal):
    promptCanvas.btnDefault.visible = false
  else:
    promptCanvas.btnDefault.visible = true
    promptCanvas.btnDefault.connect("pressed", _on_resetToDefault)

  match type:
    PromptTypes.info:
      promptCanvas.btnCancel.visible = false
    PromptTypes.int:
      promptCanvas.numEdit.value = 0 if startVal == null else startVal
      promptCanvas.numEdit.step = 1
      promptCanvas.numEdit.rounded = true
      promptCanvas.numEdit.get_line_edit().connect("text_submitted", _on_submit)
      promptCanvas.numEdit.visible = true
      promptCanvas.numEdit.get_line_edit().grab_focus()
    PromptTypes.confirm:
      promptCanvas.btnCancel.text = "cancel"
      promptCanvas.btnOk.text = "ok"
    PromptTypes.bool:
      promptCanvas.btnCancel.text = "false"
      promptCanvas.btnOk.text = "true"
    PromptTypes.multiLineString:
      promptCanvas.textEdit.text = '' if startVal == null else startVal
      promptCanvas.textEdit.visible = true
      promptCanvas.textEdit.grab_focus()
    PromptTypes.string:
      promptCanvas.strEdit.text = '' if startVal == null else startVal
      promptCanvas.strEdit.connect("text_submitted", _on_submit)
      promptCanvas.strEdit.visible = true
      promptCanvas.strEdit.grab_focus()
    PromptTypes.float:
      promptCanvas.numEdit.value = 0.0 if startVal == null else startVal
      promptCanvas.numEdit.rounded = false
      promptCanvas.numEdit.step = .1
      promptCanvas.numEdit.get_line_edit().connect("text_submitted", _on_submit)
      promptCanvas.numEdit.visible = true
      promptCanvas.numEdit.get_line_edit().grab_focus()
    PromptTypes.rgb:
      promptCanvas.colEdit.visible = true
      promptCanvas.colEdit.edit_alpha = false
      promptCanvas.colEdit.color = startVal
      promptCanvas.colEdit.connect("popup_closed", _on_submit)
    PromptTypes.rgba:
      promptCanvas.colEdit.visible = true
      promptCanvas.colEdit.edit_alpha = true
      promptCanvas.colEdit.color = startVal
      promptCanvas.colEdit.connect("popup_closed", _on_submit)
    PromptTypes._enum:
      promptCanvas.enumEdit.clear()
      for thing: String in singleArrValues:
        promptCanvas.enumEdit.add_item(thing)
      promptCanvas.enumEdit.select(-1 if startVal == null else startVal)
      promptCanvas.enumEdit.connect("item_selected", _on_submit)
      promptCanvas.enumEdit.visible = true
      promptCanvas.enumEdit.grab_focus()
      promptCanvas.btnOk.visible = false
    # PromptTypes._enum:
    #   promptCanvas.enumEdit.clear()
    #   for thing: String in singleArrValues:
    #     promptCanvas.enumEdit.add_item(thing)
    #   promptCanvas.enumEdit.select(-1 if startVal == null else singleArrValues.find(startVal))
    #   promptCanvas.enumEdit.connect("item_selected", _on_submit)
    #   promptCanvas.enumEdit.visible = true
    #   promptCanvas.enumEdit.grab_focus()
    #   promptCanvas.btnOk.visible = false

  promptCanvas.btnOk.connect("pressed", _on_submit)
  promptCanvas.btnCancel.connect("pressed", _on_cancel)
  promptCanvas.visible = true
  promptPromise = Promise.new()
  var confirmed = await promptPromise.wait()
  if same(confirmed, "default"):
    promptCanvas.queue_free.call_deferred()
    return default

  var val: Variant
  match type:
    PromptTypes.confirm: val = confirmed
    PromptTypes.bool: val = confirmed
    PromptTypes.string: val = promptCanvas.strEdit.text if confirmed else startVal
    PromptTypes.multiLineString: val = promptCanvas.textEdit.text if confirmed else startVal
    PromptTypes.float: val = float(promptCanvas.numEdit.value) if confirmed else startVal
    PromptTypes.int: val = int(promptCanvas.numEdit.value) if confirmed else startVal
    PromptTypes._enum: val = int(promptCanvas.enumEdit.selected) if confirmed else startVal
    # PromptTypes._enum: val = singleArrValues[int(promptCanvas.enumEdit.selected)] if confirmed else startVal
    PromptTypes.rgb: val = promptCanvas.colEdit.color
    PromptTypes.rgba: val = promptCanvas.colEdit.color
  Input.mouse_mode = lastMouseMode
  promptCanvas.queue_free.call_deferred()
  return val

func _on_resetToDefault() -> void:
  openMsgBoxCount -= 1
  promptPromise.resolve("default")
func _on_submit(text: Variant = null) -> void:
  openMsgBoxCount -= 1
  promptPromise.resolve(true)
func _on_cancel() -> void:
  openMsgBoxCount -= 1
  promptPromise.resolve(false)

# var __pressedKeys = []

func _input(event: InputEvent) -> void:
  if !InputMap.has_action("quit"): return
  # if event is InputEventKey:
  #   if event.pressed and event.keycode not in __pressedKeys:
  #     __pressedKeys.push_back(event.keycode)
  #   elif event.keycode in __pressedKeys:
  #     __pressedKeys.erase(event.keycode)
  # localInput(event)

# func isActionJustPressedWithNoExtraMods(thing: String) -> bool:
#   return event.is_action_pressed(thing) and isActionPressedWithNoExtraMods(thing)
# # func isActionJustReleasedWithNoExtraMods(thing: String) -> bool:
# #   return Input.is_action_just_released(thing) and isActionPressedWithNoExtraMods(thing)
# func isActionPressedWithNoExtraMods(thing: String) -> bool:
#   var actions: Array = InputMap.action_get_events(thing).map(func(e: InputEvent) -> Dictionary:
#     if "button_index" in e:
#       return {
#         "which": "mouse",
#         "button": e.button_index,
#         "c": e.ctrl_pressed,
#         "a": e.alt_pressed,
#         "s": e.shift_pressed,
#         "m": e.meta_pressed
#       }
#     else:
#       return {
#         "which": "key",
#         "key": e.physical_keycode,
#         "c": e.ctrl_pressed,
#         "a": e.alt_pressed,
#         "s": e.shift_pressed,
#         "m": e.meta_pressed
#       }
#     )
#   # log.pp(actions)
#   for action in actions:
#     if action.which == "key":
#       if Input.is_key_pressed(action.key) \
#       and Input.is_key_pressed(KEY_CTRL) == action.c \
#       and Input.is_key_pressed(KEY_ALT) == action.a \
#       and Input.is_key_pressed(KEY_SHIFT) == action.s \
#       and Input.is_key_pressed(KEY_META) == action.m \
#       :
#         return true
#     elif action.which == "mouse":
#       if Input.is_mouse_button_pressed(action.button) \
#       and Input.is_key_pressed(KEY_CTRL) == action.c \
#       and Input.is_key_pressed(KEY_ALT) == action.a \
#       and Input.is_key_pressed(KEY_SHIFT) == action.s \
#       and Input.is_key_pressed(KEY_META) == action.m \
#       :
#         return true
#   return false

class cache:
  var cache := {}
  var _data := {}
  func _init() -> void: pass
  func __has(thing: Variant) -> bool:
    if "lastinp" in self._data:
      log.err("lastinp should not exist", self )
      return false
    self._data.lastinp = thing
    return thing in self.cache
  func __get() -> Variant:
    if "lastinp" not in self._data:
      log.err("No lastinp", self )
      return
    var val: Variant = self.cache[ self._data.lastinp]
    self._data.erase("lastinp")
    return val
  func __set(value: Variant) -> Variant:
    if "lastinp" not in self._data:
      log.err("No lastinp", self )
      return
    self.cache[ self._data.lastinp] = value
    self._data.erase("lastinp")
    return value

func remove_recursive(directory: String) -> void:
  for dir_name in DirAccess.get_directories_at(directory):
    remove_recursive(directory.path_join(dir_name))
  for file_name in DirAccess.get_files_at(directory):
    DirAccess.remove_absolute(directory.path_join(file_name))

  DirAccess.remove_absolute(directory)

var regexCache: cache = cache.new()
var regMatchCache: cache = cache.new()
func regMatch(str: String, reg: String) -> Variant:
  if regMatchCache.__has([reg, str]):
    return regMatchCache.__get()
  var reg2: RegEx
  if regexCache.__has(reg):
    reg2 = regexCache.__get()
  else:
    reg2 = regexCache.__set(RegEx.create_from_string(reg))
  var res := reg2.search(str)
  if not res: return regMatchCache.__set(res)
  var out := []
  for i in range(0, res.get_group_count() + 1):
    out.push_back(res.get_string(i))
  return regMatchCache.__set(out)

var regMatchAllCache: cache = cache.new()
func regMatchAll(str: String, reg: String) -> Variant:
  if regMatchAllCache.__has([reg, str]):
    return regMatchAllCache.__get()
  var reg2: RegEx
  if regexCache.__has(reg):
    reg2 = regexCache.__get()
  else:
    reg2 = regexCache.__set(RegEx.create_from_string(reg))
  var res := reg2.search_all(str)
  var out := []
  for j in len(res):
    out.append([])
    for i in range(0, res[j].get_group_count() + 1):
      out[len(out) - 1].push_back(res[j].get_string(i))
  return regMatchAllCache.__set(out)

var regReplaceCache: cache = cache.new()
func regReplace(str: String, reg: String, with: String, all:=true) -> String:
  if regReplaceCache.__has([reg, str, with, all]):
    return regReplaceCache.__get()
  var reg2: RegEx
  if regexCache.__has(reg):
    reg2 = regexCache.__get()
  else:
    reg2 = regexCache.__set(RegEx.create_from_string(reg))
  reg2.compile(reg)
  return regReplaceCache.__set(reg2.sub(str, with, all))

# const filepath = {
# }

func same(x: Variant, y: Variant) -> bool:
  return typeof(x) == typeof(y) && x == y

func randstr(length:=10, fromchars:="qwertyuiopasdfghjklzxcvbnm1234567890~!@#$%^&*()_+-={ }[']\\|;:\",.<>/?`") -> String:
  var s := ''
  for i in range(length):
    s += (fromchars[randfrom(0, len(fromchars) - 2)])
  return s

var wait_until_wait_list := []
func waituntil(cb: Callable) -> Signal:
  var sig := "wait until signal - " + randstr(30)
  add_user_signal(sig)
  wait_until_wait_list.append([sig, cb])
  return Signal(self , sig)

# class link:
#   static var links = []
#   static func create(varname, node, cb=func(a):
#     return a, prop="text"):
#     link.links.append({"node": node, "varname": varname, "prop": prop, "val": null, "cb": cb})
#   # s=set because error when name is set
#   static func s(varname, val):
#     for l in link.links:
#       if l.node == varname:
#         l.val = val
#         l.node[l.prop] = l.cb(val)

# class lableformat:
#   static var lableformats := {}
#   static func create(name, label, format):
#     global.lableformat.lableformats[name] = {"text": format, "node": label}
#   static func update(name, newtext: Dictionary):
#     var keys = newtext.keys();
#     var temp = global.lableformat.lableformats[name]
#     var node = temp.node
#     var text = temp.text
#     for key in keys:
#       var val = newtext[key]
#       text = text.replace("{" + str(key) + "}", str(val))
#     node.text = text

  # for link in global.link.links:
  #   if link.node.is_inside_tree() and link.node.is_node_ready():
  #     link.node[link.prop] = link.cb.call(link.val)
func dictmap(dict, cb):
  for key in dict:
    dict[key] = cb.call(key, dict[key])
  return dict

class timer:
  static var time: float = 0
  static var started: bool = false
  static func reset() -> void:
    timer.time = 0
  static func format(temptime: Variant = "DJKASDHjkaDHJkashdjkAS") -> String:
    var time: float = timer.time if global.same(temptime, "DJKASDHjkaDHJkashdjkAS") else float(temptime)
    var minutes: float = time / 60
    var seconds: float = fmod(time, 60)
    var milliseconds: float = fmod(time, 1) * 100
    return "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
  static func stop() -> void:
    timer.started = false
  static func start() -> void:
    timer.started = true

func debuguistart() -> void:
  event.trigger("debugui start")

func debuguiclear() -> void:
  if event.triggers.has("debugui clear"):
    event.trigger("debugui clear")

func debuguiadd(name: String, val: String) -> void:
  if event.triggers.has("debugui add"):
    event.trigger("debugui add", name, val)

class path:
  static func abs(p: String) -> String:
    if OS.has_feature("editor"):
      return ProjectSettings.globalize_path(p)
    if global.starts_with(p, "res://"):
      return OS.get_executable_path().get_base_dir() + '/' + p.substr(6)
    return p

  static func join(path1: String, path2:="", path3:="", path4:="") -> String:
    var fullPath := path1
    if len(path2):
      var slash := 0
      if global.ends_with(fullPath, "/"):
        slash += 1
      if global.starts_with(path2, "/"):
        slash += 1
      match slash:
        0: fullPath += "/" + path2
        1: fullPath += path2
        2: fullPath += global.regReplace(path2, '^/', '')
    if len(path3):
      var slash := 0
      if global.ends_with(fullPath, "/"):
        slash += 1
      if global.starts_with(path3, "/"):
        slash += 1
      match slash:
        0: fullPath += "/" + path3
        1: fullPath += path3
        2: fullPath += global.regReplace(path3, '^/', '')
    if len(path4):
      var slash := 0
      if global.ends_with(fullPath, "/"):
        slash += 1
      if global.starts_with(path4, "/"):
        slash += 1
      match slash:
        0: fullPath += "/" + path4
        1: fullPath += path4
        2: fullPath += global.regReplace(path4, '^/', '')
    return global.regReplace(fullPath, r"\s*/+\s*$", '').strip_edges().replace("\\", "/")
    # return global.regReplace(parsePath(fullPath), r"\s*/+\s*$", '').strip_edges().replace("\\", "/")
    # return parsePath((global.regReplace(path1 + "/" + path2 + "/" + path3 + "/" + path4, "(?<!res:)/{2,}", "/")

class tilemap:
  static func save(tile_map: TileMap) -> Array:
    var layers: int = tile_map.get_layers_count()
    var tile_map_layers := []
    tile_map_layers.resize(layers)
    for layer in layers:
      tile_map_layers[layer] = tile_map.get("layer_%s/tile_data" % layer)
    return tile_map_layers
  static func load(tile_map: TileMap, data: Array) -> void:
    for layer in data.size():
      var tiles = data[layer]
      tile_map.set('layer_%s/tile_data' % layer, tiles)

class file:
  static func write(p: String, text: Variant, asjson:=true) -> void:
    # p = path.parsePath(p)
    FileAccess.open(p, FileAccess.WRITE_READ).store_string(JSON.stringify(text, "  " if OS.has_feature("editor") else '') if asjson else text)
  static func isFile(p: String) -> bool:
    return !!FileAccess.open(p, FileAccess.READ)
  static func read(p: String, asjson:=true, default:='') -> Variant:
    # p = path.parsePath(p)
    var f := FileAccess.open(p, FileAccess.READ)
    if !f:
      f = FileAccess.open(p, FileAccess.WRITE_READ)
      if f:
        f.store_string(default)
      else:
        log.err(p)
      return JSON.parse_string(default) if asjson else default
      # return null if asjson else default
    if asjson:
      if JSON.parse_string(f.get_as_text()) != null:
        return JSON.parse_string(f.get_as_text())
      else:
        if JSON.parse_string(default) != null:
          return JSON.parse_string(default)
        else: return default
    else:
      return f.get_as_text()
class arr:
  static func getcount(array: Array, count: int) -> Variant:
    var newarr := []
    for i in range(count):
      if array.size() == 0: return null
      newarr.append(array[0])
      array.remove_at(0)
    return newarr
class event:
  static var triggers: Dictionary = {}
  static func trigger(msg: String, data1: Variant = "AHDSJKHDASJK", data2: Variant = "AHDSJKHDASJK", data3: Variant = "AHDSJKHDASJK") -> void:
    if !msg in triggers:
      log.error('no triggers set for call', msg)
      return
    for cb: Callable in triggers[msg]:
      if cb != null and cb.is_valid():
        var default := "AHDSJKHDASJK"
        if global.same(data3, default):
          if global.same(data2, default):
            if global.same(data1, default):
              cb.call()
            else:
              cb.call(data1)
          else:
            cb.call(data1, data2)
        else:
          cb.call(data1, data2, data3)
  static func off(obj: Dictionary) -> void:
    var msg: String = obj.msg
    var i: int = obj.index
    if !msg in triggers:
      log.error(triggers, 'cant remove ' + str(i) + ' from ' + msg + ' because ' + msg + ' doesnt exist')
      return
    if len(triggers[msg]) <= i:
      log.error(triggers[msg], 'cant remove ' + str(i) + ' from ' + msg + ' because ' + str(i) + ' doesnt exist in ' + msg)
      return
    triggers[msg][i] = null
  static func on(msg: String, cb: Callable) -> Dictionary:
    if !msg in triggers:
      triggers[msg] = []
    triggers[msg].append(cb)
    return {'msg': msg, 'index': len(triggers[msg]) - 1}

func sinFrom(start: float, end: float, time: float, speed: float = 1) -> float:
  # Calculate the sine value, ensuring it starts at 0 when time is 0
  var sine_value = (sin(time * speed - PI / 2) + 1) / 2 # Shifted to start at 0
  return lerp(start, end, sine_value)

# class InputManager:
#   func _init(_init_key_names):
#     self.key_names = _init_key_names
#     for key in self._data.key_names.keys():
#       self.unpress(key)

#     _update_key_press_states()
#   var trypress = {}
#   var key_names = {}
#   var KEY_MAX_BUFFER: int = 15

#   func pressed(key) -> int:
#     return !!trypress[key].pressed

#   func just_pressed(key) -> int:
#     var ret = !!trypress[key].just_pressed
#     if ret:
#       trypress[key].just_pressed = 0
#     return ret

#   func just_released(key) -> int:
#     return Input.is_action_just_released(key_names[key])
#   func compare(neg, pos) -> int:
#     var input_dir = 0
#     if self.pressed(neg) == self.pressed(pos):
#       input_dir = 0
#     elif self.pressed(neg) and not self.pressed(pos):
#       input_dir = -1
#     elif self.pressed(pos):
#       input_dir = 1
#     return input_dir
#   func unpress(key):
#     trypress[key] = {
#       "pressed": 0,
#       "just_pressed": 0,
#     }
#   func press(key) -> void:
#     trypress[key] = {
#       "pressed": KEY_MAX_BUFFER,
#       "just_pressed": KEY_MAX_BUFFER,
#     }
#   func _update_key_press_states() -> void:
#     for key in self._data.key_names.keys():
#       if !key_names[key]: continue
#       if event.is_action_pressed(key_names[key]):
#         trypress[key].just_pressed = KEY_MAX_BUFFER
#       elif trypress[key].just_pressed:
#         trypress[key].just_pressed -= 1

#       if Input.is_action_pressed(key_names[key]):
#         trypress[key].pressed = 1
#       else:
#         unpress(key)

func wait(time: float = 0, ignore_time_scale: bool = false) -> Variant:
  if time == 0:
    return await get_tree().process_frame
  return await get_tree().create_timer(time / 1000.0, true, false, ignore_time_scale).timeout

func starts_with(x: String, y: String) -> bool:
  return x.substr(0, len(y)) == y
func ends_with(x: String, y: String) -> bool:
  return x.substr(len(x) - len(y)) == y

func randfrom(min: float, max: float) -> int:
  # if global.same(max, "unset"):
  #   return min[randfrom(0, len(min) - 1)]
  return int(randf() * (max - min + 1) + min)

func rerange(val: Variant, low1: Variant, high1: Variant, low2: Variant, high2: Variant) -> Variant:
  if typeof(val) == typeof(0) or typeof(val) == typeof(0.0):
    val = float(val)
    low1 = float(low1)
    high1 = float(high1)
  if typeof(low2) == typeof(0) or typeof(low2) == typeof(0.0):
    low2 = float(low2)
    high2 = float(high2)
  return ((val - low1) / (high1 - low1)) * (high2 - low2) + low2

var tick: float = 0
var stopTicking := false
func _physics_process(delta: float) -> void:
  if openMsgBoxCount: return
  if stopTicking: return
  tick += delta

func clearLow(v):
  match typeof(v):
    TYPE_VECTOR2:
      if is_zero_approx(v.x): v.x = 0
      if is_zero_approx(v.y): v.y = 0
    TYPE_VECTOR2I:
      if is_zero_approx(v.x): v.x = 0
      if is_zero_approx(v.y): v.y = 0
    TYPE_FLOAT:
      if is_zero_approx(v): v = 0
    TYPE_INT:
      log.err("no use of int here!!!")
    _:
      log.warn("clearLow: unknown type", type_string(typeof(v)))
      breakpoint
  return v

# local game only data

var player: Player
var level: Node2D

var hoveredBlocks: Array = []:
  get():
    hoveredBlocks = hoveredBlocks.filter(isAlive)
    return hoveredBlocks
var selectedBlockOffset: Vector2
var selectedBlock: EditorBlock = null
var editorInScaleMode := false
var editorInRotateMode := false

var scaleOnTopSide := true
var scaleOnBottomSide := false
var scaleOnRightSide := false
var scaleOnLeftSide := false
var showEditorUi := false
var selectedBrush: Node
var justPaintedBlock: EditorBlock = null
var gridSize: Vector2 = Vector2(5, 5)
var selectedBlockStartPosition: Vector2
var selectedBlockStartScale: Vector2
var selectedBlockStartRotation: float

var selecting := false
func selectBlock() -> void:
  if selecting: return
  selecting = true
  # select the top hovered block
  # log.pp(hoveredBlocks, selectedBlock, 1)
  var block: EditorBlock = hoveredBlocks.pop_front()
  selectedBlock = block
  lastSelectedBlock = block
  var bpos: Vector2 = block.position
  var mpos: Vector2 = player.get_global_mouse_position()
  selectedBlockStartPosition = bpos
  selectedBlockStartScale = block.scale
  selectedBlockStartRotation = block.rotation
  selectedBlockOffset = Vector2(bpos.x - mpos.x, bpos.y - mpos.y)
  var sizeInPx: Vector2 = selectedBlock.ghost.texture.get_size() * selectedBlock.scale * selectedBlock.ghost.scale
  selectedBlockOffset = round((selectedBlockOffset) / gridSize) * gridSize + (sizeInPx / 2)
  ui.blockMenu.showBlockMenu()
  hoveredBlocks.push_back(block)
  set_deferred("selecting", false)

var lastSelectedBlock: EditorBlock:
  set(val):
    lastSelectedBlock = val
    if not val:
      ui.blockMenu.clearItems()
    # else:
    #   ui.blockMenu.showBlockMenu()
  get():
    return lastSelectedBlock
var lastSelectedBrush: Node2D

func updateGridSize():
  if Input.is_action_pressed(&"editor_disable_grid_snap"):
    gridSize = Vector2(1, 1)
  else:
    if selectedBlock:
      gridSize = Vector2(global.useropts.blockGridSnapSize, global.useropts.blockGridSnapSize)
  # gridSize = Vector2(global.useropts.smallBlockGridSnapSize, global.useropts.smallBlockGridSnapSize)
  # match selectedBlock.bigSnapX:
  #   selectedBlock.BigSnapStr.ALWAYS:
  #     gridSize.x = global.useropts.largeBlockGridSnapSize
  #   selectedBlock.BigSnapStr.DEFAULT:
  #     gridSize.x = global.useropts.smallBlockGridSnapSize if Input.is_action_pressed(&"try_use_small_snap") else global.useropts.largeBlockGridSnapSize
  #   selectedBlock.BigSnapStr.NEVER:
  #     gridSize.x = global.useropts.largeBlockGridSnapSize
  # match selectedBlock.bigSnapY:
  #   selectedBlock.BigSnapStr.ALWAYS:
  #     gridSize.y = global.useropts.largeBlockGridSnapSize
  #   selectedBlock.BigSnapStr.DEFAULT:
  #     gridSize.y = global.useropts.smallBlockGridSnapSize if Input.is_action_pressed(&"try_use_small_snap") else global.useropts.largeBlockGridSnapSize
  #   selectedBlock.BigSnapStr.NEVER:
  #     gridSize.y = global.useropts.largeBlockGridSnapSize

var mouseMoveStartPos = null
var mouseMovedFarEnoughToStartDrag = false

func localProcess(delta: float) -> void:
  sendSignals()
  if not global.useropts: return
  updateGridSize()
  if FileAccess.file_exists(path.abs("res://filesToOpen")):
    var data = sds.loadDataFromFile(path.abs("res://filesToOpen"))
    file.write(path.abs("res://process"), str(OS.get_process_id()), false)
    tryAndGetMapZipsFromArr(data)
    DirAccess.remove_absolute(path.abs("res://filesToOpen"))
  if not player: return
  # if a block is selected
  if selectedBlock or (selectedBrush and selectedBrush.selected == 2):
    var mpos: Vector2 = selectedBlock.get_global_mouse_position() if selectedBlock else selectedBrush.get_global_mouse_position()
    if mouseMoveStartPos == null:
      mouseMoveStartPos = mpos
    if mouseMovedFarEnoughToStartDrag or (mouseMoveStartPos - mpos).length() >= useropts.minDistBeforeBlockDraggingStarts:
      mouseMovedFarEnoughToStartDrag = true
    else:
      mpos = mouseMoveStartPos
    if Input.is_key_pressed(KEY_ESCAPE):
      var b = selectedBlock
      b.global_position = selectedBlockStartPosition
      b.scale = selectedBlockStartScale
      b.rotation = selectedBlockStartRotation
      var moveDist = b.global_position - b.startPosition
      setBlockStartPos(b)
      b.onEditorMove(moveDist)
      selectedBlock = null
      return
    player.moving = 2
    # when trying to rotate blocks
    if editorInRotateMode && selectedBlock \
    and (selectedBlock.EDITOR_OPTION_rotate \
    or global.useropts.allowRotatingAnything):
      # handled in localinput now
      pass
    # when trying to scale blocks
    elif editorInScaleMode && selectedBlock \
    and (selectedBlock.EDITOR_OPTION_scale \
    or global.useropts.allowScalingAnything):
      if !scaleOnTopSide \
      and !scaleOnBottomSide \
      and !scaleOnLeftSide \
      and !scaleOnRightSide \
      : return
      if not mouseMovedFarEnoughToStartDrag: return
      var r = selectedBlock.rotation
      var b = selectedBlock
      var startPos = selectedBlock.global_position
      # gridSize = gridSize.rotated(r)
      var testrot = -r
      # mpos = mpos.rotated(testrot)
      # mpos = round(mpos / gridSize) * gridSize
      # startPos = round(startPos / gridSize) * gridSize

      # sizeInPx = sizeInPx.rotated(-deg_to_rad(-b.startRotation_degrees))
      var scale = b.scale.rotated(testrot)
      # log.pp(b.rotation_degrees, b.rect.right)
      var top_edge: float = (startPos - (b.sizeInPx.rotated(testrot) / 2.0)).y
      var bottom_edge: float = (startPos + (b.sizeInPx.rotated(testrot) / 2.0)).y
      var right_edge: float = (startPos + (b.sizeInPx.rotated(testrot) / 2.0)).x
      var left_edge: float = (startPos - (b.sizeInPx.rotated(testrot) / 2.0)).x
      var offset = Vector2.ZERO
      # scale on the selected sides
      var mouseDistInPx: float
      if scaleOnTopSide:
        mouseDistInPx = (top_edge - mpos.y)
        mouseDistInPx = round(mouseDistInPx / gridSize.y) * gridSize.y
        scale.y = (scale.y + (mouseDistInPx / b.sizeInPx.rotated(testrot).y * scale.y))
        offset -= Vector2(0, mouseDistInPx / 2)
      elif scaleOnBottomSide:
        mouseDistInPx = (mpos.y - bottom_edge)
        mouseDistInPx = round(mouseDistInPx / gridSize.y) * gridSize.y
        scale.y = (scale.y + (mouseDistInPx / b.sizeInPx.rotated(testrot).y * scale.y))
        offset += Vector2(0, mouseDistInPx / 2)
      if scaleOnLeftSide:
        mouseDistInPx = (left_edge - mpos.x)
        mouseDistInPx = round(mouseDistInPx / gridSize.x) * gridSize.x
        scale.x = (scale.x + (mouseDistInPx / b.sizeInPx.rotated(testrot).x * scale.x))
        offset -= Vector2(mouseDistInPx / 2, 0)
      elif scaleOnRightSide:
        mouseDistInPx = (mpos.x - right_edge)
        mouseDistInPx = round(mouseDistInPx / gridSize.x) * gridSize.x
        scale.x = (scale.x + (mouseDistInPx / b.sizeInPx.rotated(testrot).x * scale.x))
        offset += Vector2(mouseDistInPx / 2, 0)
      # log.pp(scaleOnTopSide, scaleOnBottomSide, scaleOnLeftSide, scaleOnRightSide, mouseDistInPx, mpos, bottom_edge)
      b.global_position = startPos + offset
      # b.global_position = round((b.global_position) / gridSize) * gridSize
      var moveMouse := func(pos: Vector2) -> void:
        Input.warp_mouse(pos * Vector2(get_viewport().get_stretch_transform().x.x, get_viewport().get_stretch_transform().y.y))
      # make block no less than 10% default size
      var mousePos := get_viewport().get_mouse_position()
      var minSize := Vector2(5, 5) / 700.0
      # var minSize := 0.1 / 7.0
      # need to make it stop moving - cant figure out how yet
      if scale.x < minSize.x:
        # scale.x = minSize.x
        if scaleOnLeftSide:
          scaleOnLeftSide = false
          scaleOnRightSide = true
          moveMouse.call(mousePos + Vector2(minSize.x * 700, 0))
        else:
          scaleOnLeftSide = true
          scaleOnRightSide = false
          moveMouse.call(mousePos - Vector2(minSize.x * 700, 0))

      if scale.y < minSize.y:
        # scale.y = minSize.y
        if scaleOnTopSide:
          scaleOnTopSide = false
          scaleOnBottomSide = true
          moveMouse.call(mousePos + Vector2(0, minSize.y * 700))
        else:
          scaleOnTopSide = true
          scaleOnBottomSide = false
          moveMouse.call(mousePos - Vector2(0, minSize.y * 700))
      # log.pp(minSize, scale)
      scale.x = clamp(scale.x, minSize.x, 2500.0 / 7.0)
      scale.y = clamp(scale.y, minSize.y, 2500.0 / 7.0)
      b.scale = scale.rotated(-testrot)
      global.setEditorUiState(true)
      var moveDist = b.global_position - b.startPosition
      setBlockStartPos(b)
      b.onEditorMove(moveDist)
    else:
      # if trying to create new block
      if justPaintedBlock:
        selectedBlock = justPaintedBlock
        selectedBlock.isBeingPlaced = true
        selectedBlockOffset = Vector2.ZERO
        # log.pp(selectedBlock.ghost, selectedBlock.id)
        var sizeInPx: Vector2 = selectedBlock.ghost.texture.get_size() * selectedBlock.scale * selectedBlock.ghost.scale
        selectedBlockOffset = round((selectedBlockOffset) / gridSize) * gridSize + (sizeInPx / 2)
      # if you have clicked on a block in the editor bar
      if not justPaintedBlock and selectedBrush and selectedBrush.selected == 2:
        justPaintedBlock = load("res://scenes/blocks/" + selectedBrush.blockName + "/main.tscn").instantiate()
        # if lastSelectedBlock and (selectedBrush.blockName == lastSelectedBlock.id):
        #   justPaintedBlock.scale = lastSelectedBlock.scale
        #   justPaintedBlock.rotation_degrees = lastSelectedBlock.rotation_degrees
        #   justPaintedBlock.selectedOptions = lastSelectedBlock.selectedOptions.duplicate()
        # else:
        if justPaintedBlock.normalScale:
          justPaintedBlock.scale = Vector2(1, 1)
        else:
          justPaintedBlock.scale = Vector2(1, 1) / 7
        justPaintedBlock.rotation_degrees = rad_to_deg(player.defaultAngle) \
        if justPaintedBlock.EDITOR_OPTION_rotate \
        else 0.0
        justPaintedBlock.id = blockNames[selectedBrush.id]
        justPaintedBlock.isBeingPlaced = true
        lastSelectedBrush = selectedBrush
        # create a new block
        # justPaintedBlock.scale = selectedBrush.normalScale
        # justPaintedBlock.startScale = selectedBrush.normalScale
        justPaintedBlock.global_position = mpos
        setBlockStartPos(justPaintedBlock)
        level.get_node("blocks").add_child(justPaintedBlock)
        # after creating the block recall this to update the position
        localProcess(0)

      # if trying to move a block
      else:
        # check if block scale is odd
        var b = selectedBlock
        b.global_position = mpos + selectedBlockOffset if mouseMovedFarEnoughToStartDrag else selectedBlockStartPosition
        if mouseMovedFarEnoughToStartDrag:
          snapToGrid(b, gridSize)
        var moveDist = b.global_position - b.startPosition
        setBlockStartPos(b)
        b.onEditorMove(moveDist)
      if justPaintedBlock:
        lastSelectedBlock = justPaintedBlock
      if selectedBlock:
        lastSelectedBlock = selectedBlock
  else:
    mouseMoveStartPos = null
    mouseMovedFarEnoughToStartDrag = false
func snapToGrid(b: EditorBlock, gridSize: Vector2) -> void:
  var extraOffset: Vector2 = Vector2.ZERO
  var isXOnOddScale
  var isYOnOddScale
  if b.oddScaleOffsetForce.x:
    isXOnOddScale = b.oddScaleOffsetForce.x == 1
  else:
    isXOnOddScale = (fmod(abs(b.sizeInPx.rotated(b.rotation).x) + (gridSize.x / 2), gridSize.x * 2)) > (gridSize.x)
  if b.oddScaleOffsetForce.y:
    isYOnOddScale = b.oddScaleOffsetForce.y == 1
  else:
    isYOnOddScale = (fmod(abs(b.sizeInPx.rotated(b.rotation).y) + (gridSize.x / 2), gridSize.y * 2)) > (gridSize.y)
  # offset the block on the sides that are odd to make it align with the grid
  extraOffset = Vector2(
    (gridSize.x / 2.0) if isXOnOddScale else 0.0,
    (gridSize.y / 2.0) if isYOnOddScale else 0.0,
  )
  # log.pp(isXOnOddScale, isYOnOddScale, extraOffset)
  # log.pp(isXOnOddScale, isYOnOddScale, extraOffset, b.sizeInPx, b.defaultSizeInPx)

  b.global_position = b.global_position - (b.sizeInPx / 2)

  var offset = (b.global_position - selectedBlockStartPosition)
  if Input.is_action_pressed(&"invert_single_axis_align") != global.useropts.singleAxisAlignByDefault:
    if abs(offset.x) > abs(offset.y):
      offset.y = 0
    elif abs(offset.x) < abs(offset.y):
      offset.x = 0
  b.global_position = selectedBlockStartPosition + offset
  b.global_position = round((b.global_position + extraOffset) / gridSize) * gridSize - extraOffset

func setBlockStartPos(block: Node) -> void:
  block.startPosition = block.position
  # if block != rotresetBlock:
  block.startRotation_degrees = block.rotation_degrees
  block.startScale = block.scale

var boxSelectDrawStartPos: Vector2 = Vector2.ZERO
var boxSelectRealStartPos: Vector2 = Vector2.ZERO
var boxSelectDrawEndPos: Vector2 = Vector2.ZERO
var boxSelectRealEndPos: Vector2 = Vector2.ZERO
var lastMousePos: Vector2 = Vector2.ZERO
var isFakeMouseMovement := false
var hideNonGhosts := false

func moveBlockZ(block, ud):
  if selectedBlock:
    var blocks = level.get_node("blocks")
    var idx = 0
    var startIdx = selectedBlock.get_index()
    var overlapings = selectedBlock.ghost \
      .get_node("collider").get_overlapping_areas() \
      .filter(func(e): return e.name == "collider") \
      .map(func(e): return e.get_parent().get_parent().get_index())
    overlapings.sort()
    if ud == "down":
      overlapings.reverse()
    for i in overlapings:
      if ud == "up":
        if i > startIdx: break
        elif i < startIdx:
          idx = i - 1
      elif ud == "down":
        if i < startIdx: break
        elif i > startIdx:
          idx = i + 1
    log.pp('moveBlockZ', overlapings, startIdx, idx)
    if idx:
      blocks.move_child(selectedBlock, idx)

func duplicate_block(block: EditorBlock) -> EditorBlock:
  var newBlock: EditorBlock = load("res://scenes/blocks/" + block.id + "/main.tscn").instantiate()
  newBlock.scale = block.scale
  newBlock.rotation_degrees = block.rotation_degrees
  newBlock.selectedOptions = block.selectedOptions.duplicate()
  newBlock.id = block.id
  level.get_node("blocks").add_child(newBlock)
  setBlockStartPos(newBlock)
  return newBlock

var copiedBlockData := {
  'position': Vector2.ZERO,
  'scale': Vector2(1, 1),
  'rotation': 0,
}

var lastRotatedBlock: EditorBlock

func _unhandled_input(event: InputEvent) -> void:
  if !InputMap.has_action("quit"): return
  if event is InputEventMouseMotion and event.relative == Vector2.ZERO: return
  if event is InputEventMouseMotion and isFakeMouseMovement:
    isFakeMouseMovement = false
    return
  if openMsgBoxCount: return
  if event.is_action_pressed(&"copy_block_position", false, true):
    if lastSelectedBlock:
      copiedBlockData.position = lastSelectedBlock.startPosition
  if event.is_action_pressed(&"copy_block_scale", false, true):
    if lastSelectedBlock:
      copiedBlockData.scale = lastSelectedBlock.scale
  if event.is_action_pressed(&"copy_block_rotation", false, true):
    if lastSelectedBlock:
      copiedBlockData.rotation = lastSelectedBlock.rotation
      # DisplayServer.clipboard_set(str(lastSelectedBlock.startPosition.x) + " " + str(lastSelectedBlock.startPosition.y))
  if event.is_action_pressed(&"paste_block_position", false, true):
    if lastSelectedBlock:
      if selectedBlock:
        selectedBlock = null
      var dist = lastSelectedBlock.startPosition - copiedBlockData.position
      lastSelectedBlock.startPosition = copiedBlockData.position
      lastSelectedBlock.onEditorMove(dist)
      lastSelectedBlock.onEditorMoveEnded()
      lastSelectedBlock.respawn()
  if event.is_action_pressed(&"paste_block_scale", false, true):
    if lastSelectedBlock:
      if selectedBlock:
        selectedBlock = null
      lastSelectedBlock.scale = copiedBlockData.scale
      setBlockStartPos(lastSelectedBlock)
      lastSelectedBlock.onEditorMove(Vector2.ZERO)
      lastSelectedBlock.onEditorMoveEnded()
      lastSelectedBlock.respawn()
  if event.is_action_pressed(&"paste_block_rotation", false, true):
    if lastSelectedBlock:
      if selectedBlock:
        selectedBlock = null
      lastSelectedBlock.rotation = copiedBlockData.rotation
      setBlockStartPos(lastSelectedBlock)
      lastSelectedBlock.onEditorMove(Vector2.ZERO)
      lastSelectedBlock.onEditorMoveEnded()
      lastSelectedBlock.respawn()
  if event.is_action_pressed(&"toggle_hide_non_ghosts", false, true):
    # ToastParty.error('a')
    # ToastParty.info('a')
    # ToastParty.success('a')
    hideNonGhosts = !hideNonGhosts
  if event.is_action_pressed(&"edit_level_mods", false, true):
    ui.modifiers.toggleEditor()
  if Input.is_action_pressed(&"editor_box_select", true):
    if level and is_instance_valid(level):
      boxSelectDrawEndPos = get_viewport().get_mouse_position()
      boxSelectRealEndPos = player.get_global_mouse_position()
      level.boxSelectDrawingNode.updateRect()
  if event.is_action_pressed(&"editor_box_select", false, true):
    if level and is_instance_valid(level):
      boxSelectDrawStartPos = get_viewport().get_mouse_position()
      boxSelectRealStartPos = player.get_global_mouse_position()
  if Input.is_action_just_released(&"editor_box_select", false) and boxSelectDrawStartPos:
    if level and is_instance_valid(level):
      boxSelectDrawEndPos = get_viewport().get_mouse_position()
      boxSelectRealEndPos = player.get_global_mouse_position()
      boxSelectReleased()
  if event.is_action_pressed(&"block_z_up"):
    moveBlockZ(selectedBlock, "up")
  if event.is_action_pressed(&"block_z_down"):
    moveBlockZ(selectedBlock, "down")
  if Input.is_action_just_released(&"editor_select"):
    if selectedBlock:
      selectedBlock.onEditorMove(Vector2.ZERO)
      selectedBlock = null
    else:
      if not Input.is_action_pressed(&"editor_pan", true):
        boxSelect_selectedBlocks = []
      # selectedBlock._ready.call(false)
  if event.is_action_pressed(&"new_level_file", false, true):
    if mainLevelName and level and is_instance_valid(level):
      createNewLevelFile(mainLevelName)
  if event.is_action_pressed(&"new_map_folder", false, true):
    await createNewMapFolder()
    if get_tree().current_scene.name == &"main menu":
      get_tree().current_scene.loadLocalLevelList()
  if event.is_action_pressed(&"duplicate_block", false, true):
    if boxSelect_selectedBlocks.filter(func(e): return e.id and not e.DONT_SAVE):
      var targetBlock: EditorBlock = lastSelectedBlock if lastSelectedBlock in boxSelect_selectedBlocks else boxSelect_selectedBlocks[0]
      var mpos := targetBlock.get_global_mouse_position()
      var diff = targetBlock.startPosition - mpos
      if diff.length() < 150:
        diff -= Vector2(300, 0)
        player.camLockPos += Vector2(300, 0)
      var arr: Array[EditorBlock] = []
      for block in boxSelect_selectedBlocks.filter(func(e): return e.id and not e.DONT_SAVE):
        if block == player.root: return
        if !isAlive(block): return
        var posOffset = mpos - block.startPosition
        var newBlock := duplicate_block(block)
        newBlock.global_position = mpos - posOffset - diff
        setBlockStartPos(newBlock)
        arr.append(newBlock)
      boxSelect_selectedBlocks = arr
    else:
      # log.pp(lastSelectedBrush, lastSelectedBlock)
      if lastSelectedBlock:
        selectedBrush = lastSelectedBrush
        selectedBrush.selected = 2
        justPaintedBlock = load("res://scenes/blocks/" + lastSelectedBlock.id + "/main.tscn").instantiate()
        justPaintedBlock.scale = lastSelectedBlock.scale
        justPaintedBlock.rotation_degrees = lastSelectedBlock.rotation_degrees
        justPaintedBlock.selectedOptions = lastSelectedBlock.selectedOptions.duplicate()
        justPaintedBlock.id = lastSelectedBlock.id
        # lastSelectedBrush = selectedBrush
        level.get_node("blocks").add_child(justPaintedBlock)
        justPaintedBlock.global_position = justPaintedBlock.get_global_mouse_position()
        setBlockStartPos(justPaintedBlock)
        localProcess(0)
        lastSelectedBrush.selected = 0
        selectedBrush.selected = 0
        # log.pp(justPaintedBlock.selectedOptions)
  if event.is_action_pressed(&"toggle_fullscreen", false, true):
    fullscreen()
  if event.is_action_pressed(&"editor_select"):
    if selectedBlock:
      selectedBlock.onEditorMove(Vector2.ZERO)

  if !Input.is_action_pressed(&"editor_select"):
    editorInScaleMode = Input.is_action_pressed(&"editor_scale")

  if not editorInScaleMode:
    if not editorInRotateMode and Input.is_action_pressed(&"editor_rotate") and !Input.is_action_pressed(&"editor_select"):
      lastMousePos = Vector2.ZERO
    if !lastMousePos and selectedBlock:
      lastMousePos = selectedBlock.get_viewport_transform() * selectedBlock.global_position
    if editorInRotateMode \
      and !Input.is_action_pressed(&"editor_select") \
      and lastRotatedBlock \
      and lastRotatedBlock == lastSelectedBlock \
    :
      lastSelectedBlock.onEditorRotateEnd()
    editorInRotateMode = Input.is_action_pressed(&"editor_rotate")
  if editorInRotateMode and event is InputEventMouseMotion and event.screen_relative:
    if selectedBlock \
      and (selectedBlock.EDITOR_OPTION_rotate \
      or global.useropts.allowRotatingAnything) and lastMousePos:
      lastRotatedBlock = selectedBlock
      var mpos: Vector2 = selectedBlock.get_global_mouse_position()
      selectedBlock.look_at(mpos)
      selectedBlock.rotation_degrees += selectedBlock.mouseRotationOffset
      if !Input.is_action_pressed(&"editor_disable_grid_snap"):
        selectedBlock.rotation_degrees = round(selectedBlock.rotation_degrees / 15) * 15
      selectedBlock.rotation = selectedBlock.rotation
      selectedBlock.onEditorRotate()
      setBlockStartPos(selectedBlock)
      if useropts.mouseLockDistanceWhileRotating:
        var direction := (mpos - selectedBlock.global_position).normalized().rotated(-player.get_node("Camera2D").global_rotation)
        var newMousePos: Vector2 = (
          (
            selectedBlock.get_viewport_transform() * selectedBlock.global_position
          ) + (
            direction * useropts.mouseLockDistanceWhileRotating
          )
        )
        isFakeMouseMovement = true
        Input.warp_mouse(newMousePos)
  if event.is_action_pressed(&"exit_inner_level", false, true):
    if level and is_instance_valid(level):
      if len(loadedLevels) > 1:
        loadedLevels.pop_back()
        await level.loadLevel(currentLevel().name)
        loadBlockData()
        await wait()
        setEditorUiState(false)
        # player.state = player.States.levelLoading
        player.deathPosition = currentLevel().spawnPoint
        player.lastSpawnPoint = currentLevel().spawnPoint
        player.camLockPos = Vector2.ZERO
        player.goto(player.deathPosition)
        player.die(1, false, true)
        await wait()
        player.die(15, false, true)
        # player.die(3, false, true)
        global.tick = global.currentLevel().tick
        # savePlayerLevelData()
  if event.is_action_pressed(&"save", false, true):
    if level and is_instance_valid(level):
      level.save()
  if Input.is_action_pressed(&"editor_delete", true):
    if !isAlive(level): return
    for block in boxSelect_selectedBlocks:
      if !is_instance_valid(block): return
      if block == global.player.root: return
      if block.is_queued_for_deletion(): return
      if block in hoveredBlocks:
        hoveredBlocks.erase(block)
      block.onDelete()
      block.queue_free.call_deferred()
    boxSelect_selectedBlocks = []
    # log.pp(selectedBlock, lastSelectedBlock)
    if selectedBlock && is_instance_valid(selectedBlock):
      if selectedBlock == global.player.root: return
      if selectedBlock in hoveredBlocks:
        hoveredBlocks.erase(selectedBlock)
      # var temp = selectedBlock.duplicate()
      # temp.id = selectedBlock.id
      # temp.scale = selectedBlock.scale
      # temp.rotation_degrees = selectedBlock.rotation_degrees
      # temp.selectedOptions = selectedBlock.selectedOptions.duplicate()
      lastSelectedBlock = selectedBlock.duplicate()
      lastSelectedBlock.selectedOptions = selectedBlock.selectedOptions.duplicate()
      lastSelectedBlock.id = selectedBlock.id
      selectedBlock.onDelete()
      selectedBlock.queue_free.call_deferred()
      selectedBlock = null
    else:
      if useropts.deleteLastSelectedBlockIfNoBlockIsCurrentlySelected:
        log.pp(selectedBlock, lastSelectedBlock)
        if lastSelectedBlock && is_instance_valid(lastSelectedBlock):
          if lastSelectedBlock == global.player.root: return
          if lastSelectedBlock in hoveredBlocks:
            hoveredBlocks.erase(lastSelectedBlock)
          var temp = lastSelectedBlock.duplicate()
          temp.id = lastSelectedBlock.id
          temp.scale = lastSelectedBlock.scale
          temp.rotation_degrees = lastSelectedBlock.rotation_degrees
          temp.selectedOptions = lastSelectedBlock.selectedOptions.duplicate()
          lastSelectedBlock.onDelete()
          lastSelectedBlock.queue_free.call_deferred()
          lastSelectedBlock = temp
          ui.blockMenu.clearItems()

  if mainLevelName:
    if event.is_action_pressed(&"reload_map_from_last_save", true):
      loadMap.call_deferred(mainLevelName, true)
    if event.is_action_pressed(&"fully_reload_map", true):
      loadMap.call_deferred(mainLevelName, false)
  if event.is_action_pressed(&"toggle_hitboxes", false, true):
    hitboxesShown = !hitboxesShown
    get_tree().set_debug_collisions_hint(hitboxesShown)
    var tree := get_tree()
    var node_stack: Array[Node] = [tree.get_root()]
    while not node_stack.is_empty():
      var node: Node = node_stack.pop_back()
      if is_instance_valid(node):
        if node is CollisionShape2D or node is CollisionPolygon2D or node is RayCast2D:
          node.visible = true
          node.queue_redraw()
        node_stack.append_array(node.get_children())
    hitboxTypesChanged.emit()
  if event.is_action_pressed(&"quit", false, true):
    quitGame()
  if event.is_action_pressed(&"move_player_to_mouse", false, true):
    if player and is_instance_valid(player):
      # move player feet to mouse position
      if player.state == player.States.dead:
        player.stopDying()
      player.state = player.States.falling
      player.activePole = null
      player.activePulley = null
      player.activeCannon = null
      player.goto(player.get_global_mouse_position() - player.root.startPosition + player.applyRot(0, -17))
  if event.is_action_pressed(&"toggle_pause", false, true):
    if level and is_instance_valid(level):
      global.stopTicking = !global.stopTicking
      # global.tick = 0
  if event.is_action_pressed(&"load", false, true):
    if useropts.saveOnExit:
      if level and is_instance_valid(level):
        level.save()
    get_tree().change_scene_to_file.call_deferred("res://scenes/main menu/main_menu.tscn")
    Input.mouse_mode = Input.MOUSE_MODE_CONFINED

  if event.is_action_pressed(&"move_selected_left"):
    if !lastSelectedBlock or !is_instance_valid(lastSelectedBlock): return
    updateGridSize()
    var moveDist = Vector2(-1, 0) * gridSize
    lastSelectedBlock.global_position += moveDist
    setBlockStartPos(lastSelectedBlock)
    lastSelectedBlock.onEditorMove(moveDist)
  if event.is_action_pressed(&"move_selected_right"):
    if !lastSelectedBlock or !is_instance_valid(lastSelectedBlock): return
    updateGridSize()
    var moveDist = Vector2(1, 0) * gridSize
    lastSelectedBlock.global_position += moveDist
    setBlockStartPos(lastSelectedBlock)
    lastSelectedBlock.onEditorMove(moveDist)
  if event.is_action_pressed(&"move_selected_up"):
    if !lastSelectedBlock or !is_instance_valid(lastSelectedBlock): return
    updateGridSize()
    var moveDist = Vector2(0, -1) * gridSize
    lastSelectedBlock.global_position += moveDist
    setBlockStartPos(lastSelectedBlock)
    lastSelectedBlock.onEditorMove(moveDist)
  if event.is_action_pressed(&"move_selected_down"):
    if !lastSelectedBlock or !is_instance_valid(lastSelectedBlock): return
    updateGridSize()
    var moveDist = Vector2(0, 1) * gridSize
    lastSelectedBlock.global_position += moveDist
    setBlockStartPos(lastSelectedBlock)
    lastSelectedBlock.onEditorMove(moveDist)
  if showEditorUi:
    for block in blockNames:
      if !block: continue
      if event.is_action_pressed("CREATE NEW - " + block.replace("/", "_"), false, true):
        log.pp(block)
        selectedBrush = lastSelectedBrush
        selectedBrush.selected = 2
        justPaintedBlock = load("res://scenes/blocks/" + block + "/main.tscn").instantiate()
        if justPaintedBlock.normalScale:
          justPaintedBlock.scale = Vector2(1, 1)
        else:
          justPaintedBlock.scale = Vector2(1, 1) / 7
        justPaintedBlock.rotation_degrees = rad_to_deg(player.defaultAngle) \
        if justPaintedBlock.EDITOR_OPTION_rotate \
        else 0.0
        justPaintedBlock.id = block
        lastSelectedBrush = selectedBrush
        level.get_node("blocks").add_child(justPaintedBlock)
        justPaintedBlock.global_position = level.get_global_mouse_position()
        setBlockStartPos(justPaintedBlock)
        localProcess(0)
        lastSelectedBrush.selected = 0
        selectedBrush.selected = 0

var levelFolderPath: String
var loadedLevels: Array
var mainLevelName: String
var beatLevels: Array
var levelOpts: Dictionary
var loadingLevel = false

func loadInnerLevel(innerLevel: String) -> void:
  if loadingLevel: return
  loadingLevel = true
  player.state = player.States.levelLoading
  # breakpoint
  currentLevel().spawnPoint = player.global_position - player.root.global_position
  currentLevel().up_direction = player.up_direction
  currentLevel().autoRunDirection = player.autoRunDirection

  var prevLevelDataFound = false
  for level in beatLevels:
    if level.name == innerLevel:
      prevLevelDataFound = true
      global.loadedLevels.append(level)
      # beatLevels.erase(level)
      break
  if !prevLevelDataFound:
    global.loadedLevels.append(newLevelSaveData(innerLevel))

  if currentLevel().name not in levelOpts.stages:
    log.err("ADD SETTINGS for " + currentLevel().name + " to options file")
  await wait()
  await level.loadLevel(innerLevel)
  player.deathPosition = player.lastSpawnPoint
  player.camLockPos = Vector2.ZERO
  player.goto(player.deathPosition)
  player.die(1, false, true)
  await wait()
  player.die(15, false, true)
  loadBlockData()
  await savePlayerLevelData()
  loadingLevel = false
  # log.pp(loadedLevels, beatLevels)

func win() -> void:
  var justBeatLevel = loadedLevels.pop_back()
  for level in beatLevels:
    if level.name == justBeatLevel.name:
      beatLevels.erase(level)
      break
  beatLevels.append(justBeatLevel)
  if len(loadedLevels) == 0:
    log.pp("PLAYER WINS!!!")
    if global.useropts.saveLevelOnWin:
      loadedLevels.append(beatLevels.pop_back())
      level.save()
    loadMap.call_deferred(mainLevelName, true)
    return
  # log.pp(currentLevel().spawnPoint, currentLevel())
  await wait()
  await level.loadLevel(currentLevel().name)
  # log.pp(loadedLevels, beatLevels)
  player.lastSpawnPoint = currentLevel().spawnPoint
  player.deathPosition = player.lastSpawnPoint
  player.camLockPos = Vector2.ZERO
  player.goto(player.deathPosition)
  player.die(1, false, true)
  await wait()
  player.die(15, false, true)
  await wait()
  loadBlockData()
  savePlayerLevelData()

var savingPlayerLevelData := false

func savePlayerLevelData(blocksOnly:=false) -> void:
  if savingPlayerLevelData: return
  savingPlayerLevelData = true
  await wait()
  var saveData: Variant = sds.loadDataFromFile(path.abs("res://saves/saves.sds"), {})
  # breakpoint
  saveData[mainLevelName] = {
    "lastSpawnPoint": player.lastSpawnPoint,
    "loadedLevels": loadedLevels,
    "beatLevels": beatLevels,
  }
  if !blocksOnly:
    currentLevel().tick = global.tick if currentLevelSettings("saveTick") else 0.0
    currentLevel().up_direction = player.up_direction
    currentLevel().autoRunDirection = player.autoRunDirection
  currentLevel().blockSaveData = saveBlockData()
  # log.pp(saveData[mainLevelName], player.up_direction, currentLevel())
  sds.saveDataToFile(path.abs("res://saves/saves.sds"), saveData)
  savingPlayerLevelData = false

func newLevelSaveData(levelname):
  return {
    "name": levelname,
    "spawnPoint": Vector2.ZERO,
    "up_direction": Vector2.UP,
    "autoRunDirection": 1,
    "tick": 0,
    "blockSaveData": {},
  }.duplicate()

func saveBlockData():
  var blockSaveData = {}
  var blockIds = {}
  for block: EditorBlock in level.get_node("blocks").get_children():
    if block.id not in blockIds:
      blockIds[block.id] = 0
    blockIds[block.id] += 1
    var dataToSave: Array[String] = block.onSave()
    if dataToSave:
      if block.id not in blockSaveData:
        blockSaveData[block.id] = {}
      if blockIds[block.id] not in blockSaveData[block.id]:
        blockSaveData[block.id][blockIds[block.id]] = {}
      for thing in dataToSave:
        blockSaveData[block.id][blockIds[block.id]][thing] = block.get(thing)
  return blockSaveData

func loadMap(levelPackName: String, loadFromSave: bool) -> bool:
  # log.pp("loadFromSave", loadFromSave)
  var saveData: Variant = sds.loadDataFromFile(path.abs("res://saves/saves.sds"), {})
  if levelPackName in saveData:
    saveData = saveData[levelPackName]
  else:
    saveData = null
  # save the name globally
  mainLevelName = levelPackName
  # Engine.time_scale = 1
  # log.pp("Loading Level Pack:", levelPackName)
  levelFolderPath = path.abs(path.join(MAP_FOLDER, levelPackName))
  var levelPackInfo: Variant = await loadMapInfo(levelPackName)
  if !levelPackInfo: return false
  var startFile := path.join(levelFolderPath, levelPackInfo.start + '.sds')
  if !file.isFile(startFile):
    log.err("LEVEL NOT FOUND!", startFile)
    return false
  # levelPackInfo.version = int(levelPackInfo.version)
  if not same(levelPackInfo.version, VERSION):
    var gameVersionIsNewer: bool = VERSION > levelPackInfo.version
    if gameVersionIsNewer:
      if useropts.warnWhenOpeningLevelInNewerGameVersion:
        var data = await prompt(
          "this level was last saved in version " +
          str(levelPackInfo.version) +
          " and the current version is " + str(VERSION) +
          ". Do you want to load this level?\n" +
          "> the current game version is newer than what the level was made in"
          , PromptTypes.confirm
        )
        if not data: return false
    else:
      if useropts.warnWhenOpeningLevelInOlderGameVersion:
        var data = await prompt(
          "this level was last saved in version " +
          str(levelPackInfo.version) +
          " and the current version is " + str(VERSION) +
          ". Do you want to load this level?\n" +
          "< the current game version might not have all the features needed to play this level"
          , PromptTypes.confirm
        )
        if not data: return false
  levelOpts = levelPackInfo

  if loadFromSave and saveData:
    loadedLevels = saveData.loadedLevels
    beatLevels = saveData.beatLevels
  else:
    loadedLevels = [
      newLevelSaveData(levelPackInfo.start)
    ]
    beatLevels = []
  get_tree().change_scene_to_file("res://scenes/level/level.tscn")
  await level.loadLevel(currentLevel().name)
  loadBlockData()
  await wait()
  setEditorUiState(false)
  player.camLockPos = Vector2.ZERO
  # player.state = player.States.levelLoading
  if loadFromSave and saveData:
    player.deathPosition = saveData.lastSpawnPoint
    player.lastSpawnPoint = saveData.lastSpawnPoint
  else:
    player.deathPosition = Vector2.ZERO
    player.lastSpawnPoint = Vector2.ZERO
  player.camLockPos = Vector2.ZERO
  player.goto(player.deathPosition)
  player.die(1, false, true)
  await wait()
  player.die(15, false, true)
  global.tick = global.currentLevel().tick
  return true

func loadBlockData():
  if not "blockSaveData" in currentLevel(): return
  var blockSaveData = currentLevel().blockSaveData
  global.tick = currentLevel().tick
  player.up_direction = currentLevel().up_direction
  var blockIds = {}
  for block: EditorBlock in level.get_node("blocks").get_children():
    if block.id not in blockIds:
      blockIds[block.id] = 0
    blockIds[block.id] += 1
    var dataToLoad: Array[String] = block.onSave()
    if block.id not in blockSaveData: continue
    if blockIds[block.id] not in blockSaveData[block.id]: continue
    if dataToLoad:
      for thing in dataToLoad:
        if thing not in blockSaveData[block.id][blockIds[block.id]]: continue
        block.set(thing, blockSaveData[block.id][blockIds[block.id]][thing])
      block.onDataLoaded()
  for block: EditorBlock in level.get_node("blocks").get_children():
    block.onAllDataLoaded()

func currentLevel() -> Dictionary:
  return loadedLevels[len(loadedLevels) - 1]

var totalLevelCount

func loadMapInfo(levelPackName: String) -> Variant:
  var options: Variant = sds.loadDataFromFile(path.join(MAP_FOLDER, levelPackName, "/options.sds"))

  totalLevelCount = len(DirAccess.get_files_at(path.join(MAP_FOLDER, levelPackName))) - 1

  if !options:
    log.err("CREATE OPTIONS FILE!!!", levelPackName)
    return
  return options

# gray
# red
# orange
# yellow
# light green
# dark green
# aqua
# blue
# dark blue
# purple
# pink

var useropts := {}

func animate(speed: int, steps: Array) -> float:
  # animation time is based on global.tick
  # dict arr is like [
  #   {
  #     "until": 120, // time to stop this animation at - this animation goes from 0 to 120
  #     "from": - 189.0, // number returned at the start of this animation
  #     "to": - 350.0 // number returned at the end of this animation
  #   },
  #   {
  #     "until": 130, // this animation goes from 120 to 130
  #     "from": - 350.0,
  #     "to": - 189.0
  #   },
  #   {
  #     "until": 160,
  #     "from": - 189.0,
  #     "to": - 189
  #   }
  # ]
  var currentTime := fmod(global.tick * speed, steps[len(steps) - 1].until)
  var newOffset: float
  var prevTime: float = 0
  for i in range(0, len(steps)):
    if currentTime < steps[i].until:
      newOffset = global.rerange(currentTime, prevTime, steps[i].until, steps[i].from, steps[i].to)
      break
    else:
      prevTime = steps[i].until
  return newOffset

func createNewLevelFile(levelPackName: String, levelName: Variant = null) -> bool:
  if not levelName:
    levelName = await prompt("enter the level name", PromptTypes.string, "")
  levelPackName = fixPath(levelPackName)
  levelName = fixPath(levelName)
  if !levelPackName or !levelName:
    return false
  var fullDirPath := path.join(MAP_FOLDER, levelPackName)
  var opts: Dictionary = sds.loadDataFromFile(path.join(fullDirPath, "options.sds"))
  var d = defaultLevelSettings.duplicate()
  opts.stages[levelName] = d
  if useropts.randomizeLevelModifiersOnLevelCreation:
    for k in d:
      if k in ['saveTick', 'color']: continue
      if typeof(d[k]) == TYPE_BOOL:
        d[k] = !!randfrom(0, 1)
        continue
      match k:
        "jumpCount":
          d[k] = randfrom(0, 2)
        _:
          log.err("random setting not set for: ", k)
    if d.autoRun and randfrom(1, 3) == 1:
      d.autoRun = false
    if d.autoRun and not d.canDoWallJump and not d.canDoWallSlide:
      d.autoRun = false
    if d.autoRun and not d.canDoWallJump:
      d.canDoWallJump = true
    if d.canDoWallJump and not d.canDoWallSlide:
      d.canDoWallSlide = true
  d.color = randfrom(1, 11)
  file.write(path.join(fullDirPath, levelName + ".sds"), '', false)
  sds.saveDataToFile(path.join(fullDirPath, "options.sds"), opts)
  return true

func fixPath(path):
  var badChars := "[^()[\\]\\w\\d'!@#$%^& _-]+"
  return regReplace(path, badChars, "_").strip_edges()

func createNewMapFolder() -> Variant:
  var foldername: String = await prompt("Enter the name of the map", PromptTypes.string, '')
  foldername = fixPath(foldername)
  if !foldername: return
  var fullDirPath := path.join(MAP_FOLDER, foldername)
  if DirAccess.dir_exists_absolute(fullDirPath):
    await prompt("Folder already exists!")
    return
  var startLevel: String = await prompt("Enter the name of the first level:", PromptTypes.string, "hub")
  startLevel = fixPath(startLevel)
  DirAccess.make_dir_absolute(fullDirPath)
  sds.saveDataToFile(path.join(fullDirPath, "options.sds"),
    {
      "start": startLevel,
      "author": await prompt(
        "Enter your name",
        PromptTypes.string,
        "",
      ),
      "description": "",
      "version": VERSION,
      "stages": {
      }
    }
  )
  if ! await createNewLevelFile(foldername, startLevel):
    return false
  # var o = []
  # log.pp(OS.execute("cmd", [
  #   "/c",
  #   'mklink /J "' +
  #   path.join(MAP_FOLDER, foldername, "/custom blocks") +
  #   '" "' +
  #   path.abs("res://custom blocks") +
  #   '"'
  # ], o), o)
  return foldername

const defaultLevelSettings = {
  "color": 1,
  "changeSpeedOnSlopes": false,
  "saveTick": false,
  "jumpCount": 1,
  "autoRun": false,
  "canDoWallHang": true,
  "canDoWallSlide": true,
  "canDoWallJump": true,
}

func currentLevelSettings(key: Variant = null) -> Variant:
  if key:
    var data: Variant = levelOpts.stages[currentLevel().name][key] \
    if key in levelOpts.stages[currentLevel().name] else \
    defaultLevelSettings[key]
    return data
  var data: Dictionary = defaultLevelSettings.duplicate()
  for k in levelOpts.stages[currentLevel().name]:
    data[k] = levelOpts.stages[currentLevel().name][k]
  return data

func fullscreen(state: int = 0) -> void:
  var mode := DisplayServer.window_get_mode()
  match state:
    -1:
      if mode == DisplayServer.WINDOW_MODE_WINDOWED: return
      DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
    0: # toggle
      DisplayServer.window_set_mode(
        DisplayServer.WINDOW_MODE_FULLSCREEN \
        if mode == DisplayServer.WINDOW_MODE_WINDOWED \
        else DisplayServer.WINDOW_MODE_WINDOWED
      )
    1:
      if mode == DisplayServer.WINDOW_MODE_FULLSCREEN: return
      DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

@onready var VERSION := int(file.read("VERSION", false, "-1"))

func localReady() -> void:
#   log.test([123,
#   [
#   "res://scenes/blocks/selectedBorder.tres/images/editorBar.png",
#   "res://scenes/blocks/selectedBorder.tres/images/1.png",
#   "res://scenes/blocks/selectedBorder.tres/images/unpressed.png",
#   "res://scenes/blocks/selectedBorder.tres/images/ghost.png",
#   112
#   ],
# " does not exist, ITEM:",
# "res://scenes/blocks/selectedBorder.tres"
# ])
#   log.test([
#   [
#     [
#       [
#         {
#           's': [
#             "res://scenes/blocks/selectedBorder.tres/images/editorBar.png",
#             "res://scenes/blocks/selectedBorder.tres/images/1.png",
#             "res://scenes/blocks/selectedBorder.tres/images/unpressed.png",
#             "res://scenes/blocks/selectedBorder.tres/images/ghost.png",
#             112
#           ]
#         }
#       ]
#     ]
#   ],
#   " does not exist, ITEM:",
#   "res://scenes/blocks/selectedBorder.tres"
# ])
  # log.test(Color('#ff00006b').to_rgba32())
  DirAccess.make_dir_recursive_absolute(MAP_FOLDER)
  DirAccess.make_dir_recursive_absolute(path.abs("res://downloaded maps/"))
  DirAccess.make_dir_recursive_absolute(path.abs("res://saves/"))
  DirAccess.make_dir_recursive_absolute(path.abs("res://exports/"))
  DirAccess.make_dir_recursive_absolute(path.abs("res://custom blocks/"))
  get_tree().set_debug_collisions_hint(hitboxesShown)
  # const SHIFT_VALUE = 353
  # var encode_string = func encode_string(input_string: String) -> String:
  #   var encoded_string = ""
  #   for c in input_string:
  #     encoded_string += str(char(c.unicode_at(0) + SHIFT_VALUE))
  #   return encoded_string
  # await wait(1000)
  # await prompt('', PromptTypes.string, encode_string.call(await prompt("Enter a string to encode:", PromptTypes.string)))
  # createFileAssociation("vex plus plus", ["vex++"], "VEX++ map file")
  # quitGame()
  var pid = int(file.read(path.abs("res://process"), false, "0"))
  log.pp("FILEPID", pid)
  log.pp("MYPID", OS.get_process_id())
  getProcess(OS.get_process_id())
  if getProcess(pid) \
    and pid != OS.get_process_id() \
    and (('vex' in getProcess(pid)) or ("Godot" in getProcess(pid))) \
  :
    sds.saveDataToFile(path.abs("res://filesToOpen"), OS.get_cmdline_args() as Array)
    DirAccess.remove_absolute(path.abs("res://process"))
    get_tree().quit()
  else:
    file.write(path.abs("res://process"), str(OS.get_process_id()), false)
    tryAndGetMapZipsFromArr(OS.get_cmdline_args())
  loadEditorBarData()

const DEFAULT_BLOCK_LIST = [
  "basic",
  "slope",
  "path",
  "10x spike",
  "10x oneway spike",
  "10x solar spike",
  "10x inverse solar spike",
  "invisible",
  "updown",
  "downup",
  "leftRight",
  "rightLeft",
  "growing block",
  "gravity rotator",
  "water",
  "solar",
  "inverse solar",
  "pushable box",
  "microwave",
  "locked box",
  "floor button",
  "signal deactivated wall",
  "glass",
  "falling",
  "donup",
  "bouncy",
  "spark block/counterClockwise",
  "spark block/clockwise",
  "inner level",
  "goal",
  "buzsaw",
  "bouncing buzsaw",
  "cannon",
  "checkpoint",
  "closing spikes",
  "gravity down lever",
  "gravity up lever",
  "speed up lever",
  "growing buzsaw",
  "jump refresher",
  "key",
  "light switch",
  "red only light switch",
  "blue only light switch",
  "pole",
  "pole quadrant",
  "pulley",
  "quadrant",
  "rotating buzzsaw",
  "scythe",
  "shurikan spawner",
  "star",
  "laser",
  "targeting laser",
  # "ice",
  "death boundary",
  "block death boundary",
  # "basic - nowj",
  "noWJ",
  "falling spike",
  # "quad falling spikes",
  "portal",
  "bomb",
  "sticky floor",
  "arrow",
  "conveyer",
  "oneway",
  "undeath",
  "input detector",
  "player state detector",
  "not gate",
  "and gate",
  "crumbling",
  "timer",
  # "rotator",
]

func loadEditorBarData():
  var editorBarData = sds.loadDataFromFile(path.abs("res://editorBar.sds"), [])
  var tempBlockNames = []
  var unusedBlockNames = DEFAULT_BLOCK_LIST.duplicate()
  if useropts and editorBarData:
    var i = 0
    for k in editorBarData:
      for thing in editorBarData[k]:
        i += 1
        if thing in unusedBlockNames:
          unusedBlockNames.erase(thing)
        if k == 'remove':
          if InputMap.has_action("CREATE NEW - " + thing.replace("/", "_")):
            InputMap.erase_action("CREATE NEW - " + thing.replace("/", "_"))
        else:
          tempBlockNames.append(thing)
      if k != 'remove':
        while i % int(useropts.editorBarColumns) != 0:
          i += 1
          tempBlockNames.append(null)
          # tempBlockNames.append('basic')
  blockNames = tempBlockNames + unusedBlockNames

  for block in blockNames:
    if block and !InputMap.has_action("CREATE NEW - " + block.replace("/", "_")):
      InputMap.add_action("CREATE NEW - " + block.replace("/", "_"))

func _notification(what):
  if what == NOTIFICATION_PREDELETE: pass
  if what == NOTIFICATION_WM_CLOSE_REQUEST:
    quitGame()

func quitGame():
  if !useropts:
    get_tree().quit()
    return
  if 'saveOnExit' in useropts and useropts.saveOnExit:
    if level and is_instance_valid(level):
      level.save()
  if OS.get_process_id() == int(file.read(path.abs("res://process"), false)):
    DirAccess.remove_absolute(path.abs("res://process"))
  get_tree().quit()

var stretchScale: Vector2:
  get():
    return Vector2(get_viewport().get_stretch_transform().x.x, get_viewport().get_stretch_transform().y.y)

func getProcess(pid: int):
  if not pid:
    return false
  var ret = []
  OS.execute("cmd", [
    '/c',
    "tasklist | findstr \"[^,a-zA-Z0-9]" + str(pid) + "[^,a-zA-Z0-9]\""
  ], ret)
  log.pp("tasklist", ret)
  return ret[0].strip_edges()

var hitboxesShown := false

func tryAndLoadMapFromZip(from: String, to: String):
  var reader := ZIPReader.new()
  var err := reader.open(from)
  if err:
    log.warn(from, err)
    return
  to = to.strip_edges()

  # Destination directory for the extracted files (this folder must exist before extraction).
  # Not all ZIP archives put everything in a single root folder,
  # which means several files/folders may be created in `root_dir` after extraction.

  var files = reader.get_files()

  # if all files were zipped by zipping the containing folder then remove the root folder from the zip
  var startDir = ''
  var allInSameDir = true
  for file_path in files:
    if not startDir:
      startDir = regMatch(file_path, r"^[^/\\]+")
      if startDir: startDir = startDir[0]
      continue
    var d = regMatch(file_path, r"^[^/\\]+")
    if d: d = d[0]
    if !same(d, startDir):
      allInSameDir = false
      break
  var tempFiles
  if allInSameDir:
    tempFiles = (files as Array).map(func(e):
      log.pp(e)
      return e.replace(startDir + "/", '')).filter(func(e):
      return e)
  else:
    tempFiles = files
  log.pp(files, tempFiles)
  if "options.sds" not in tempFiles:
    log.err("not a valid map file", from, to, files)
    return
  log.pp("loading map from", from, "to", to)
  if DirAccess.dir_exists_absolute(to):
    OS.move_to_trash(to)
    await wait(100)
    if DirAccess.dir_exists_absolute(to):
      DirAccess.remove_absolute(to)
  DirAccess.make_dir_recursive_absolute(to)
  var root_dir = DirAccess.open(to)
  for file_path in files:
    var outpath = file_path
    if allInSameDir:
      outpath = regReplace(file_path, r"^[^/\\]+[/\\]", '')
    outpath = outpath.strip_edges()
    # If the current entry is a directory.
    log.pp(outpath, "outpath")
    if file_path.ends_with("/"):
      root_dir.make_dir_recursive(outpath)
      continue
    if FileAccess.file_exists(outpath):
      OS.move_to_trash(outpath)
      await wait(100)
      if FileAccess.file_exists(outpath):
        DirAccess.remove_absolute(outpath)
    # Write file contents, creating folders automatically when needed.
    # Not all ZIP archives are strictly ordered, so we need to do this in case
    # the file entry comes before the folder entry.
    root_dir.make_dir_recursive(root_dir.get_current_dir().path_join(outpath).get_base_dir())
    var file := FileAccess.open(root_dir.get_current_dir().path_join(outpath), FileAccess.WRITE)
    var buffer = reader.read_file(file_path)
    file.store_buffer(buffer)
    file.close()
  return true

func tryAndGetMapZipsFromArr(args) -> bool:
  var mapFound = false
  for p: String in args:
    if !p.begins_with('uid://') and FileAccess.file_exists(p):
      log.pp("tryAndGetMapZipsFromArr, found a map at:", p)
      if !('.' in p and ('/' in p or '\\' in p)): continue
      # add the intended folder to the end of the path to force it to go into the correct folder
      var moveto = path.join(MAP_FOLDER, regMatch(p, r"[/\\]([^/\\]+)\.[^/\\]+$")[1])
      if await tryAndLoadMapFromZip(p, moveto):
        mapFound = true
  if mapFound and get_tree().current_scene.name == "main menu":
    get_tree().current_scene.loadLocalLevelList()
    DisplayServer.window_move_to_foreground()
  # log.pp("get_tree().current_scene", get_tree().current_scene.name)
  return mapFound

func getAllPathsInDirectory(dir_path: String):
  var files = []
  var item
  var item_path

  var dir := DirAccess.open(dir_path)
  if dir == null: printerr("Could not open folder", dir_path); return

  dir.list_dir_begin()
  item = dir.get_next()
  while item != "":
    item_path = dir_path + "/" + item
    if dir.dir_exists(item_path):
      for thing in getAllPathsInDirectory(item_path):
        files.append(thing)
    if dir.file_exists(item_path):
      files.append(item_path)
    item = dir.get_next()
  dir.list_dir_end()

  return files
func zipDir(fromPath: String, toPath: String):
  fromPath = path.join(fromPath)
  var paths = getAllPathsInDirectory(fromPath)
  # log.pp(fromPath, toPath, paths)
  paths = paths.map(func(e):
    return e.replace(fromPath + "/", ''))
  # log.pp(paths)
  var writer = ZIPPacker.new()
  var err = writer.open(toPath)
  if err != OK: return err
  for file_name in paths:
    writer.start_file(file_name)
    var file = FileAccess.open(fromPath + "/" + file_name, FileAccess.READ)
    writer.write_file(file.get_buffer(file.get_length()))
    file.close()
    writer.close_file()

  # dir.list_dir_end()
  writer.close()
  return OK

# use OS.shell_open
# func openPathInExplorer(p: String):
#   log.pp(p)
#   OS.create_process("explorer", PackedStringArray([
#     '"' + (
#       ProjectSettings.globalize_path(p)
#       if OS.has_feature("editor") else
#       global.path.abs(p)
#     ).replace("/", "\\")
#     + '"'
#   ]))

var ui: CanvasLayer

func copyDir(source: String, destination: String):
  DirAccess.make_dir_recursive_absolute(destination)

  var source_dir = DirAccess.open(source)

  for filename in source_dir.get_files():
    source_dir.copy(
      path.join(source, filename),
      path.join(destination, filename)
    )

  for dir in source_dir.get_directories():
    copyDir(path.join(source, dir), path.join(destination, dir))

func httpGet(
  url: String,
  custom_headers: PackedStringArray = PackedStringArray(),
  method: int = 0,
  request_data: String = "",
  download_file=null,
  asjson=true
  ):
  var http_request = HTTPRequest.new()
  if download_file:
    http_request.download_file = download_file
  var promise = Promise.new()
  add_child(http_request)
  http_request.request_completed.connect(func(result, response_code, headers, body):
    # log.pp("DKLKLSADKLSDAKLKSADL", result, response_code, headers, body)
    var response
    if asjson:
      response=JSON.parse_string(body.get_string_from_utf8())
      if len(str(response)) < 100:
        log.pp(response)
    else:
      response=body
    promise.resolve({"response": response, "code": response_code})
  )

  var error = http_request.request(url, custom_headers, method, request_data)
  if error != OK:
    push_error("An error occurred in the HTTP request.")
  return await promise.wait()

func urlEncode(input: String) -> String:
  var encoded = ""
  for c in input:
    if c in 'qwertyuiopasdfghjklZxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM123789456/':
      encoded += c
    else:
      encoded += "%" + String("%02X" % (c).unicode_at(0))
  return encoded

func getToken():
  const SHIFT_VALUE = 353
  const t = 'ǈǊǕǉǖǃǀǑǂǕǀƒƒƣưƖưƕƯƪƑƯǈǐǋǔǂǓƲǋƬƔǙǀƭƔƲƻƻǑǕƳǑƨǇǃƒǙǊǙƬƓǙƘƑƱƳƑƯƧǘǘƣƬǐƶǔƧưƶưƧǘǑƤǋǂƕƲƴƶƳưƥƨǑƘǂƲǊƣƵƖ'

  # Function to decode the encoded string back to the original
  var decode_string = func decode_string(encoded_string: String) -> String:
    var decoded_string = ""
    for c in encoded_string:
      decoded_string += str(char(c.unicode_at(0) - SHIFT_VALUE))
    return decoded_string
  return decode_string.call(t)

var blockNames: Array = []

var lastPortal: Node2D = null

var defaultBlockOpts: Dictionary = {}

var popupStarted = false

func createNewBlock(data) -> EditorBlock:
  var id = data.id
  if load("res://scenes/blocks/" + id + "/main.tscn"):
    var thing = load("res://scenes/blocks/" + id + "/main.tscn").instantiate()
    thing.startPosition = Vector2(data.x, data.y)
    thing.position = Vector2(data.x, data.y)
    # log.pp(thing.normalScale)
    if thing.normalScale:
      thing.startScale = Vector2(data.w, data.h)
      thing.scale = Vector2(data.w, data.h)
    else:
      thing.startScale = Vector2(data.w / 7.0, data.h / 7.0)
      thing.scale = Vector2(data.w / 7.0, data.h / 7.0)
    thing.startRotation_degrees = data.r
    thing.rotation_degrees = data.r
    thing.id = id
    if 'options' in data:
      thing.selectedOptions = data.options
    return thing
  else:
    log.err("Error loading block", id)
  return

var boxSelect_selectedBlocks: Array[EditorBlock] = []:
  get():
    boxSelect_selectedBlocks = boxSelect_selectedBlocks.filter(isAlive)
    return boxSelect_selectedBlocks

@onready var MAP_FOLDER = path.abs('res://maps')

func boxSelectReleased():
  # boxSelect_selectedBlocks = []
  var rect = [
    Vector2(
      min(boxSelectRealStartPos.x, boxSelectRealEndPos.x),
      min(boxSelectRealStartPos.y, boxSelectRealEndPos.y)
    ),
    Vector2(
      max(boxSelectRealStartPos.x, boxSelectRealEndPos.x),
      max(boxSelectRealStartPos.y, boxSelectRealEndPos.y)
    ),
  ]
  log.pp(rect)
  for block: EditorBlock in level.get_node("blocks").get_children():
    if block.isChildOfCustomBlock: continue
    if block.EDITOR_IGNORE: continue
    var pos = block.global_position
    var size = block.sizeInPx.rotated(deg_to_rad(block.startRotation_degrees))
    if pos.x + (size.x / 2) >= rect[0][0] and pos.x - (size.x / 2) <= rect[1][0]:
      if pos.y + (size.y / 2) >= rect[0][1] and pos.y - (size.y / 2) <= rect[1][1]:
        if block not in boxSelect_selectedBlocks:
          boxSelect_selectedBlocks.append(block)

  boxSelectDrawStartPos = Vector2.ZERO
  boxSelectDrawEndPos = Vector2.ZERO
  level.boxSelectDrawingNode.updateRect()
  if boxSelect_selectedBlocks:
    lastSelectedBlock = boxSelect_selectedBlocks[0]

func isAlive(e):
  return e \
    and is_instance_valid(e) \
    and !e.is_queued_for_deletion()

var hoveredBrushes: Array[Node2D] = []

signal gravChanged
signal onEditorStateChanged

var checkpoints: Array[BlockCheckpoint] = []:
  get():
    checkpoints = checkpoints.filter(isAlive)
    return checkpoints

var portals: Array[BlockPortal] = []:
  get():
    portals = portals.filter(isAlive)
    return portals

var isFirstTimeMenuIsLoaded := true

func setEditorUiState(val):
  showEditorUi = val
  onEditorStateChanged.emit()

signal signalChanged
var activeSignals: Dictionary[int, Array] = {}:
  get():
    for id in activeSignals:
      activeSignals[id] = activeSignals[id].filter(isAlive)
    return activeSignals

var signalChanges = {}
var lastSignals: Dictionary[int, bool] = {}

func resendActiveSignals():
  # log.pp(activeSignals)
  if not isAlive(ui): return
  for id in activeSignals:
    ui.signalList.onSignalChanged(id, !!activeSignals[id], activeSignals[id])
    lastSignals[id] = !!activeSignals[id]
    # log.pp("update signal changes", activeSignals, activeSignals)
    # text += '\n' + str(id) + ': ' + str(!!activeSignals[id])
    # log.pp(id, !!activeSignals[id], activeSignals[id])
    signalChanged.emit(id, !!activeSignals[id], activeSignals[id])

func sendSignals():
  var sc = signalChanges.duplicate()
  signalChanges = {}
  # var text = ''
  if not isAlive(ui): return
  for id in sc:
    ui.signalList.onSignalChanged(id, !!activeSignals[id], sc[id])
    if id in lastSignals and (lastSignals[id] == !!activeSignals[id]): continue
    lastSignals[id] = !!activeSignals[id]
    # log.pp("update signal changes", sc, activeSignals)
    # text += '\n' + str(id) + ': ' + str(!!activeSignals[id])
    signalChanged.emit(id, !!activeSignals[id], sc[id])
  # if text:
  #   log.pp(activeSignals, text)
  # log.pp()

func sendSignal(id, node, val):
  if not id:
    log.pp("sendSignal: invalid ID provided", id, node.root.id, val)
    return
  if id not in activeSignals:
    activeSignals[id] = []
  if val:
    if node not in activeSignals[id]:
      # log.pp(node.id, "added")
      activeSignals[id].append(node)
  else:
    if node in activeSignals[id]:
      # log.pp(node.id, "removed")
      activeSignals[id].erase(node)
  if id not in signalChanges:
    signalChanges[id] = []
  signalChanges[id].append(node)
  # log.pp(signalChanges[id], id)

func onSignalChanged(cb):
  if !signalChanged.is_connected(cb):
    signalChanged.connect(cb)

var tabMenu
var hitboxTypes := {
  "attachDetector": true,
  "death": true,
  "area": true,
  "solid": true
}
signal hitboxTypesChanged

const BRANCH = "main"
const REPO_NAME = "vex-plus-plus-level-codes"

func downloadMap(version, creator, level):
  var url = (
    "https://raw.githubusercontent.com/rsa17826/" +
    REPO_NAME + "/main/levels/" +
    global.urlEncode(str(version) + '/' + creator + "/" + level) + '?rand=' + str(randf())
  )
  log.pp(url)
  await global.httpGet(url,
    PackedStringArray(),
    HTTPClient.METHOD_GET,
    '',
    global.path.abs("res://downloaded maps/" + level),
    false
  )
  if await global.tryAndGetMapZipsFromArr([global.path.abs("res://downloaded maps/" + level)]):
    ToastParty.success("Download complete\nThe map has been loaded.")
  else:
    ToastParty.error("Download failed, the map doesn't exist, or the map was invalid.")

# (?:(?:\b(?:and|or|\|\||&&)\b).*){3,}

# (?<=[\w_\]])\[(['"])([\w_]+)\1\]
# .$2
