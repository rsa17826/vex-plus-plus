@tool
extends Node

# @name same line return
# @regex :\s*(return|continue|break)\s*$
# @replace : $1
# @flags gm
# @endregex

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
      Signal(self, i[0]).emit()
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
  bool
}

func prompt(msg: String, type: PromptTypes = PromptTypes.info, default: Variant = null, singleArrValues: Variant = []) -> Variant:
  if openMsgBoxCount:
    while openMsgBoxCount:
      await wait(10)
  var lastMouseMode := Input.mouse_mode
  Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
  openMsgBoxCount += 1

  var promptCanvas := preload("res://GLOBAL/prompt.tscn").instantiate()
  get_tree().root.add_child(promptCanvas)
  promptCanvas.get_node("ColorRect").size = windowSize
  promptCanvas.get_node("ColorRect/CenterContainer").size = windowSize
  promptCanvas.promptText.text = msg

  promptCanvas.numEdit.visible = false
  promptCanvas.strEdit.visible = false
  promptCanvas.enumEdit.visible = false
  # log.pp(type)
  promptCanvas.btnCancel.text = "cancel"
  promptCanvas.btnOk.text = "ok"
  promptCanvas.btnCancel.visible = true
  match type:
    PromptTypes.info:
      promptCanvas.btnCancel.visible = false
    PromptTypes.int:
      promptCanvas.numEdit.value = 0 if default == null else default
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
    PromptTypes.string:
      promptCanvas.strEdit.text = '' if default == null else default
      promptCanvas.strEdit.connect("text_submitted", _on_submit)
      promptCanvas.strEdit.visible = true
      promptCanvas.strEdit.grab_focus()
    PromptTypes.float:
      promptCanvas.numEdit.value = 0.0 if default == null else default
      promptCanvas.numEdit.rounded = false
      promptCanvas.numEdit.step = .1
      promptCanvas.numEdit.get_line_edit().connect("text_submitted", _on_submit)
      promptCanvas.numEdit.visible = true
      promptCanvas.numEdit.get_line_edit().grab_focus()
    PromptTypes._enum:
      promptCanvas.enumEdit.clear()
      for thing: String in singleArrValues:
        promptCanvas.enumEdit.add_item(thing)
      promptCanvas.enumEdit.select(-1 if default == null else singleArrValues.find(default))
      promptCanvas.enumEdit.connect("item_selected", _on_submit)
      promptCanvas.enumEdit.visible = true
      promptCanvas.enumEdit.grab_focus()
      promptCanvas.btnOk.visible = false

  promptCanvas.btnOk.connect("pressed", _on_submit)
  promptCanvas.btnCancel.connect("pressed", _on_cancel)
  promptCanvas.visible = true
  promptPromise = Promise.new()
  var confirmed: bool = await promptPromise.wait()
  var val: Variant
  match type:
    PromptTypes.confirm: val = confirmed
    PromptTypes.bool: val = confirmed
    PromptTypes.string: val = promptCanvas.strEdit.text if confirmed else default
    PromptTypes.float: val = float(promptCanvas.numEdit.value) if confirmed else default
    PromptTypes.int: val = int(promptCanvas.numEdit.value) if confirmed else default
    PromptTypes._enum: val = singleArrValues[int(promptCanvas.enumEdit.selected)] if confirmed else default
  Input.mouse_mode = lastMouseMode
  promptCanvas.queue_free.call_deferred()
  return val

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
  localInput(event)

func isActionJustPressedWithNoExtraMods(thing: String) -> bool:
  return Input.is_action_just_pressed(thing) and isActionPressedWithNoExtraMods(thing)
func isActionJustReleasedWithNoExtraMods(thing: String) -> bool:
  return Input.is_action_just_released(thing) and isActionPressedWithNoExtraMods(thing)
func isActionPressedWithNoExtraMods(thing: String) -> bool:
  var actions: Array = InputMap.action_get_events(thing).map(func(e: InputEvent) -> Dictionary:
    return {
      "key": e.physical_keycode,
      "c": e.ctrl_pressed,
      "a": e.alt_pressed,
      "s": e.shift_pressed,
      "m": e.meta_pressed
    })
  # log.pp(actions)
  var valid: bool = false
  for action in actions:
    if Input.is_key_pressed(action.key) \
    and Input.is_key_pressed(KEY_CTRL) == action.c \
    and Input.is_key_pressed(KEY_ALT) == action.a \
    and Input.is_key_pressed(KEY_SHIFT) == action.s \
    and Input.is_key_pressed(KEY_META) == action.m \
    :
      valid = true
      break
  return valid

class cache:
  var cache := {}
  var _data := {}
  func _init() -> void:
    pass
  func __has(thing: Variant) -> bool:
    if "lastinp" in self._data:
      log.err("lastinp should not exist", self)
      return false
    self._data.lastinp = thing
    return thing in self.cache
  func __get() -> Variant:
    if "lastinp" not in self._data:
      log.err("No lastinp", self)
      return
    var val: Variant = self.cache[self._data.lastinp]
    self._data.erase("lastinp")
    return val
  func __set(value: Variant) -> Variant:
    if "lastinp" not in self._data:
      log.err("No lastinp", self)
      return
    self.cache[self._data.lastinp] = value
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

func join(joiner: Variant = "", a: Variant = "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", s: Variant = "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", d: Variant = "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", f: Variant = "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", g: Variant = "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", h: Variant = "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", j: Variant = "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", k: Variant = "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", l: Variant = "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", z: Variant = "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", x: Variant = "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", c: Variant = "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", v: Variant = "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", b: Variant = "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", n: Variant = "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", m: Variant = "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", q: Variant = "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", w: Variant = "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", e: Variant = "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", r: Variant = "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", t: Variant = "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", y: Variant = "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", u: Variant = "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", i: Variant = "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", o: Variant = "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", p: Variant = "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD") -> String:
  var temparr := [a, s, d, f, g, h, j, k, l, z, x, c, v, b, n, m, q, w, e, r, t, y, u, i, o, p]
  temparr = temparr.filter(func(e: Variant) -> bool:
    return !same(e, "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD")
    )
  return joiner.join(temparr)

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
  return Signal(self, sig)

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
  static func abs(path: String):
    return ProjectSettings.globalize_path(path) \
      if OS.has_feature("editor") else \
      global.path.parsePath(path)

  static func parsePath(p: String) -> String:
    # log.pp(1, p)
    if !OS.has_feature("editor"):
      return global.regReplace(p, 'res://', OS.get_executable_path().get_base_dir() + '/')
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
#       if Input.is_action_just_pressed(key_names[key]):
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

# local game only data

var player: Node2D
var level: Node2D

var hoveredBlocks: Array = []
var selectedBlockOffset: Vector2
var selectedBlock: Node2D = null
var editorInScaleMode := false
var editorInRotateMode := false

var scaleOnTopSide := true
var scaleOnBottomSide := false
var scaleOnRightSide := false
var scaleOnLeftSide := false
var showEditorUi := false
var selectedBrush: Node
var justPaintedBlock: Node = null
var gridSize = 25 / 5.0

func selectBlock() -> void:
  # select the top hovered block
  var block: Node2D = hoveredBlocks[0]
  hoveredBlocks.pop_front.call_deferred()
  selectedBlock = block
  lastSelectedBlock = block
  var bpos: Vector2 = block.position
  var mpos: Vector2 = player.get_global_mouse_position()
  selectedBlockOffset = Vector2(bpos.x - mpos.x, bpos.y - mpos.y)
  var sizeInPx: Vector2 = selectedBlock.ghost.texture.get_size() * selectedBlock.scale * selectedBlock.ghost.scale
  selectedBlockOffset = round((selectedBlockOffset) / gridSize) * gridSize + (sizeInPx / 2)

var lastSelectedBlock: Node2D
var lastSelectedBrush: Node2D
enum EditorModes {
  path,
  normal
}
var editorMode = EditorModes.normal

func localProcess(delta: float) -> void:
  if not global.useropts: return
  gridSize = 1 if Input.is_action_pressed("editor_disable_grid_snap") else global.useropts.blockSnapGridSize
  if FileAccess.file_exists(path.parsePath("res://filesToOpen")):
    var data = sds.loadDataFromFile(path.parsePath("res://filesToOpen"))
    file.write(path.parsePath("res://process"), str(OS.get_process_id()), false)
    tryAndGetMapZipsFromArr(data)
    DirAccess.remove_absolute(path.parsePath("res://filesToOpen"))
  if not player: return
  match editorMode:
    EditorModes.path:
      pass
    EditorModes.normal:
      # if a block is selected
      # if rotresetBlock and (not editorInScaleMode or (len(hoveredBlocks) and hoveredBlocks[0] != rotresetBlock)):
      #   rotresetBlock.rotation_degrees = rotresetBlock.startRotation_degrees
      # if editorInScaleMode and len(hoveredBlocks) && hoveredBlocks[0].is_in_group("EDITOR_OPTION_scale"):
      #   rotresetBlock = hoveredBlocks[0]
      #   rotresetBlock.rotation_degrees = 0
      #   rotresetBlock.ghost.rotation_degrees = rotresetBlock.startRotation_degrees
      # if rotresetBlock and not editorInRotateMode and not editorInScaleMode:
      #   rotresetBlock = null
      if selectedBlock or (selectedBrush and selectedBrush.selected == 2):
        var mpos: Vector2 = selectedBlock.get_global_mouse_position() if selectedBlock else selectedBrush.get_global_mouse_position()

        player.moving = 2

        # when trying to rotate blocks
        if editorInRotateMode && selectedBlock \
        and (selectedBlock.is_in_group("EDITOR_OPTION_rotate") \
        or global.useropts.allowRotatingAnything):
          selectedBlock.look_at(mpos)
          selectedBlock.rotation_degrees += 90
          selectedBlock.rotation_degrees = round(selectedBlock.rotation_degrees / 15) * 15
          setBlockStartPos(selectedBlock)
        # when trying to scale blocks
        elif editorInScaleMode && selectedBlock \
        and (selectedBlock.is_in_group("EDITOR_OPTION_scale") \
        or global.useropts.allowScalingAnything):
          var sizeInPx: Vector2 = selectedBlock.ghost.texture.get_size() * selectedBlock.scale * selectedBlock.ghost.scale

          # get the edge position in px
          var bottom_edge: float = selectedBlock.global_position.y + sizeInPx.y / 2.0
          var top_edge: float = selectedBlock.global_position.y - sizeInPx.y / 2.0
          var right_edge: float = selectedBlock.global_position.x + sizeInPx.x / 2.0
          var left_edge: float = selectedBlock.global_position.x - sizeInPx.x / 2.0

          if global.useropts.noCornerGrabsForScaling:
            # if the user doesnt want to scale corners scale only the side that has less grab area
            var width = selectedBlock.scale.x
            var height = selectedBlock.scale.y

            if scaleOnTopSide and scaleOnBottomSide:
              if width < height:
                scaleOnBottomSide = false
              else:
                scaleOnTopSide = false

            if scaleOnLeftSide and scaleOnRightSide:
              if height < width:
                scaleOnRightSide = false
              else:
                scaleOnLeftSide = false

            if scaleOnTopSide and scaleOnLeftSide:
              if width < height:
                scaleOnLeftSide = false
              else:
                scaleOnTopSide = false

            if scaleOnTopSide and scaleOnRightSide:
              if width < height:
                scaleOnRightSide = false
              else:
                scaleOnTopSide = false

            if scaleOnBottomSide and scaleOnLeftSide:
              if width < height:
                scaleOnLeftSide = false
              else:
                scaleOnBottomSide = false

            if scaleOnBottomSide and scaleOnRightSide:
              if width < height:
                scaleOnRightSide = false
              else:
                scaleOnBottomSide = false

          # scale on the selected sides
          if scaleOnTopSide:
            var mouseDIstInPx := (top_edge - mpos.y)
            mouseDIstInPx = round(mouseDIstInPx / gridSize) * gridSize
            selectedBlock.scale.y = (selectedBlock.scale.y + (mouseDIstInPx / sizeInPx.y * selectedBlock.scale.y))
            selectedBlock.global_position.y = selectedBlock.global_position.y - (mouseDIstInPx / 2)
          elif scaleOnBottomSide:
            var mouseDIstInPx := (mpos.y - bottom_edge)
            mouseDIstInPx = round(mouseDIstInPx / gridSize) * gridSize
            selectedBlock.scale.y = (selectedBlock.scale.y + (mouseDIstInPx / sizeInPx.y * selectedBlock.scale.y))
            selectedBlock.global_position.y = selectedBlock.global_position.y + (mouseDIstInPx / 2)
          if scaleOnLeftSide:
            var mouseDIstInPx := (left_edge - mpos.x)
            mouseDIstInPx = round(mouseDIstInPx / gridSize) * gridSize
            selectedBlock.scale.x = (selectedBlock.scale.x + (mouseDIstInPx / sizeInPx.x * selectedBlock.scale.x))
            selectedBlock.global_position.x = selectedBlock.global_position.x - (mouseDIstInPx / 2)
          elif scaleOnRightSide:
            var mouseDIstInPx := (mpos.x - right_edge)
            mouseDIstInPx = round(mouseDIstInPx / gridSize) * gridSize
            selectedBlock.scale.x = (selectedBlock.scale.x + (mouseDIstInPx / sizeInPx.x * selectedBlock.scale.x))
            selectedBlock.global_position.x = selectedBlock.global_position.x + (mouseDIstInPx / 2)

          var moveMouse := func(pos: Vector2) -> void:
            Input.warp_mouse(pos * Vector2(get_viewport().get_stretch_transform().x.x, get_viewport().get_stretch_transform().y.y))
          # make block no less than 10% default size
          var mousePos := get_viewport().get_mouse_position()
          var minSize := 0.1 / 7.0
          # need to make it stop moving - cant figure out how yet
          if selectedBlock.scale.x < minSize:
            selectedBlock.respawn()
            # selectedBlock.scale.x = minSize
            if scaleOnLeftSide:
              scaleOnLeftSide = false
              scaleOnRightSide = true
              moveMouse.call(mousePos + Vector2(minSize * 700, 0))
            else:
              scaleOnLeftSide = true
              scaleOnRightSide = false
              moveMouse.call(mousePos - Vector2(minSize * 700, 0))

          if selectedBlock.scale.y < minSize:
            selectedBlock.respawn()
            # selectedBlock.scale.y = minSize
            if scaleOnTopSide:
              scaleOnTopSide = false
              scaleOnBottomSide = true
              moveMouse.call(mousePos + Vector2(0, minSize * 700))
            else:
              scaleOnTopSide = true
              scaleOnBottomSide = false
              moveMouse.call(mousePos - Vector2(0, minSize * 700))

          selectedBlock.scale.x = clamp(selectedBlock.scale.x, 0.1 / 7.0, 250.0 / 7.0)
          selectedBlock.scale.y = clamp(selectedBlock.scale.y, 0.1 / 7.0, 250.0 / 7.0)
          global.showEditorUi = true
          # selectedBlock.self_modulate.a = useropts.hoveredBlockGhostAlpha
          setBlockStartPos(selectedBlock)
          selectedBlock.respawn()
        else:
          # if trying to create new block
          if justPaintedBlock:
            selectedBlock = justPaintedBlock
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
            justPaintedBlock.scale = Vector2(1, 1) / 7
            justPaintedBlock.rotation_degrees = 0
            justPaintedBlock.id = blockNames[selectedBrush.id]
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
            # get block size in pixels
            var sizeInPx: Vector2 = selectedBlock.ghost.texture.get_size() * selectedBlock.scale * selectedBlock.ghost.scale

            # check if block scale is odd
            var isYOnOddScale: Variant = str(int(selectedBlock.scale.y * 700))
            isYOnOddScale = isYOnOddScale[len(isYOnOddScale) - 1] == '5'
            var isXOnOddScale: Variant = str(int(selectedBlock.scale.x * 700))
            isXOnOddScale = isXOnOddScale[len(isXOnOddScale) - 1] == '5'

            # offset the block on the sides that are odd to make it align with the grid
            var offset := Vector2((gridSize / 2.0) if isXOnOddScale else 0.0, (gridSize / 2.0) if isYOnOddScale else 0.0)
            mpos = round((mpos - offset) / gridSize) * gridSize

            selectedBlock.global_position = round(mpos + selectedBlockOffset - (sizeInPx / 2))
            # if isYOnOddScale or isXOnOddScale:
            selectedBlock.global_position += offset
            setBlockStartPos(selectedBlock)
            # if selectedBlock.name == "player":
            #   selectedBlock.get_node("CharacterBody2D").moving = 2
            selectedBlock.respawn()
      if justPaintedBlock:
        lastSelectedBlock = justPaintedBlock
      if selectedBlock:
        lastSelectedBlock = selectedBlock
    
func setBlockStartPos(block: Node) -> void:
  block.startPosition = block.position
  # if block != rotresetBlock:
  block.startRotation_degrees = block.rotation_degrees
  block.startScale = block.scale

func localInput(event: InputEvent) -> void:
  if openMsgBoxCount: return
  if Input.is_action_just_released("editor_select"):
    if selectedBlock:
      selectedBlock.respawn()
      selectedBlock = null
      # selectedBlock._ready.call(false)
  if isActionJustPressedWithNoExtraMods("new_level_file"):
    if mainLevelName and level and is_instance_valid(level):
      createNewLevelFile(mainLevelName)
  if isActionJustPressedWithNoExtraMods("new_map_folder"):
    createNewMapFolder()
  if isActionJustPressedWithNoExtraMods("duplicate_block"):
    log.pp(lastSelectedBrush, lastSelectedBlock)
    if lastSelectedBrush and lastSelectedBlock:
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
      log.pp(justPaintedBlock.selectedOptions)
  if isActionJustPressedWithNoExtraMods("toggle_fullscreen"):
    fullscreen()
  if Input.is_action_just_pressed("editor_select"):
    if editorMode == EditorModes.path:
      if !lastSelectedBlock:
        log.err("no blocks selected")
        return
      lastSelectedBlock.selectedOptions.path += (
        "," +
        str(level.get_global_mouse_position().x - lastSelectedBlock.global_position.x) +
        "," +
        str(level.get_global_mouse_position().y - lastSelectedBlock.global_position.y)
      )
      log.pp(lastSelectedBlock.selectedOptions.path)
    else:
      if selectedBlock:
        selectedBlock.respawn()

  # dont update editor scale mode if clicking
  if !Input.is_action_pressed("editor_select"):
    editorInScaleMode = Input.is_action_pressed("editor_scale")
  if !Input.is_action_pressed("editor_select") and not editorInScaleMode:
    editorInRotateMode = Input.is_action_pressed("editor_rotate")

  if isActionJustPressedWithNoExtraMods("save"):
    if level and is_instance_valid(level):
      level.save()
  if isActionPressedWithNoExtraMods("toggle_path_editor"):
    if editorMode == EditorModes.path:
      editorMode = EditorModes.normal
    else:
      editorMode = EditorModes.path
  if isActionPressedWithNoExtraMods("editor_delete"):
    if !selectedBlock: return
    if selectedBlock == global.player.get_parent(): return
    # lastSelectedBrush = null
    hoveredBlocks.erase(selectedBlock)
    lastSelectedBlock = selectedBlock.duplicate()
    lastSelectedBlock.id = selectedBlock.id
    selectedBlock.queue_free.call_deferred()
    selectedBlock = null
  if isActionJustPressedWithNoExtraMods("reload_map_from_last_save"):
    loadMap.call_deferred(mainLevelName, true)
  if isActionJustPressedWithNoExtraMods("fully_reload_map"):
    loadMap.call_deferred(mainLevelName, false)
  if isActionJustPressedWithNoExtraMods("toggle_hitboxes"):
    hitboxesShown = !hitboxesShown
    get_tree().set_debug_collisions_hint(hitboxesShown)
    showEditorUi = !showEditorUi
    await wait(1)
    showEditorUi = !showEditorUi
  if isActionJustPressedWithNoExtraMods("quit"):
    quitGame()
  if isActionJustPressedWithNoExtraMods("move_player_to_mouse"):
    if player and is_instance_valid(player):
      player.camLockPos = Vector2.ZERO
      player.goto(player.get_global_mouse_position() - player.get_parent().startPosition)
  if isActionJustPressedWithNoExtraMods("toggle_pause"):
    if level and is_instance_valid(level):
      global.stopTicking = !global.stopTicking
      global.tick = 0
  if isActionJustPressedWithNoExtraMods("load"):
    if useropts.saveOnExit:
      if level and is_instance_valid(level):
        level.save()
    get_tree().change_scene_to_file.call_deferred("res://scenes/main menu/main_menu.tscn")
    Input.mouse_mode = Input.MOUSE_MODE_CONFINED

var levelFolderPath: String
var loadedLevels: Array
var mainLevelName: String
var beatLevels: Array
var levelOpts: Dictionary

func starFound() -> void:
  currentLevel().foundStar = true

func loadInnerLevel(innerLevel: String) -> void:
  currentLevel().spawnPoint = player.global_position - player.get_parent().global_position
  global.loadedLevels.append({"name": innerLevel, "spawnPoint": Vector2.ZERO, 'foundStar': false})
  if currentLevel().name not in levelOpts.stages:
    log.err("ADD SETTINGS for " + currentLevel().name + " to options file")
  await wait()
  level.loadLevel(innerLevel)
  player.die(0, true)
  player.deathPosition = player.lastSpawnPoint
  # log.pp(loadedLevels, beatLevels)

func win() -> void:
  beatLevels.append(loadedLevels.pop_back())
  if len(loadedLevels) == 0:
    log.pp("PLAYER WINS!!!")
    if global.useropts.saveLevelOnWin:
      loadedLevels.append(beatLevels.pop_back())
      level.save()
    loadMap.call_deferred(mainLevelName, true)
    return
  # log.pp(currentLevel().spawnPoint, currentLevel())
  await wait()
  level.loadLevel(currentLevel().name)
  # log.pp(loadedLevels, beatLevels)
  player.lastSpawnPoint = currentLevel().spawnPoint
  player.die(0, false)
  player.deathPosition = player.lastSpawnPoint

var savingPlaterLevelData := false

func savePlayerLevelData() -> void:
  if savingPlaterLevelData: return
  savingPlaterLevelData = true
  var saveData: Variant = sds.loadDataFromFile(path.parsePath("res://saves/saves.sds"), {})
  var levels := {}
  for l in loadedLevels:
    levels[l.name] = l
  for l in beatLevels:
    levels[l.name] = l
  var playerDelogPosition := player.position
  saveData[mainLevelName] = {
    "playerDelogPosition": playerDelogPosition,
    "lastSpawnPoint": player.lastSpawnPoint,
    "loadedLevels": loadedLevels,
    # .map(func(e):
    #   var ee=JSON.parse_string(JSON.stringify(e))
    #   ee.spawnPoint=[e.spawnPoint.x, e.spawnPoint.y]
    #   return ee),
    "beatLevels": beatLevels,
    # .map(func(e):
    #   var ee=JSON.parse_string(JSON.stringify(e))
    #   ee.spawnPoint=[e.spawnPoint.x, e.spawnPoint.y]
    #   return ee),
    "levels": levels
  }
  sds.saveDataToFile(path.parsePath("res://saves/saves.sds"), saveData)
  await wait(1000)
  savingPlaterLevelData = false

func loadMap(levelPackName: String, loadFromSave: bool) -> void:
  # log.pp("loadFromSave", loadFromSave)
  var saveData: Variant = sds.loadDataFromFile(path.parsePath("res://saves/saves.sds"), {})
  if levelPackName in saveData:
    saveData = saveData[levelPackName]
  else:
    saveData = null
  # save the name globaly
  mainLevelName = levelPackName
  # Engine.time_scale = 1
  # log.pp("Loading Level Pack:", levelPackName)
  levelFolderPath = path.parsePath(path.join('res://maps/', levelPackName))
  var levelPackInfo: Dictionary = await loadMapInfo(levelPackName)
  if !levelPackInfo: return
  var startFile := path.join(levelFolderPath, levelPackInfo['start'] + '.sds')
  if !file.isFile(startFile):
    log.err("LEVEL NOT FOUND!", startFile)
    return
  # levelPackInfo["version"] = int(levelPackInfo["version"])
  if not same(levelPackInfo["version"], VERSION):
    var gameVersionIsNewer: bool = VERSION > levelPackInfo["version"]
    if gameVersionIsNewer:
      if useropts.warnWhenOpeningLevelInNewerGameVersion:
        var data = await prompt(
          "this level was last saved in version " +
          str(levelPackInfo["version"]) +
          " and the current version is " + str(VERSION) +
          ". Do you want to load this level?\n" +
          "> the current game version is newer than what the level was made in"
          , PromptTypes.confirm
        )
        if not data: return
    else:
      if useropts.warnWhenOpeningLevelInOlderGameVersion:
        var data = await prompt(
          "this level was last saved in version " +
          str(levelPackInfo["version"]) +
          " and the current version is " + str(VERSION) +
          ". Do you want to load this level?\n" +
          "< the current game version might not have all the features needed to play this level"
          , PromptTypes.confirm
        )
        if not data: return
  levelOpts = levelPackInfo

  if loadFromSave and saveData:
    loadedLevels = saveData.loadedLevels
    beatLevels = saveData.beatLevels
  else:
    loadedLevels = [
      {
        "name": levelPackInfo['start'],
        "spawnPoint": Vector2.ZERO,
        "foundStar": false
      }
    ]
    beatLevels = []
  get_tree().change_scene_to_file("res://scenes/levels/level.tscn")
  await level.loadLevel(currentLevel().name)
  await wait()
  showEditorUi = false
  player.camLockPos = Vector2.ZERO
  player.die(0, false)
  # player.state = player.States.levelLoading
  if loadFromSave and saveData:
    player.deathPosition = player.lastSpawnPoint
    player.goto(saveData.playerDelogPosition)
    player.lastSpawnPoint = saveData.lastSpawnPoint
  else:
    player.goto(Vector2(0, 0))
    player.lastSpawnPoint = Vector2(0, 0)
    player.goto(Vector2(0, 0))
  global.tick = 0

func currentLevel() -> Dictionary:
  return loadedLevels[len(loadedLevels) - 1]

func loadMapInfo(levelPackName: String) -> Variant:
  var options: Variant = sds.loadDataFromFile(path.parsePath(path.join('res://maps/', levelPackName, "/options.sds")))
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

var checkpoints: Array = []

func animate(speed: int, steps: Array) -> float:
  # animation time is baised on global.tick
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

func createNewLevelFile(levelPackName: String, levelName: Variant = null) -> void:
  if not levelName:
    levelName = await prompt("enter the level name", PromptTypes.string, "")
  var fullDirPath := path.parsePath(path.join("res://maps/", levelPackName))
  var opts: Dictionary = sds.loadDataFromFile(path.join(fullDirPath, "options.sds"))
  opts.stages[levelName] = defaultLevelSettings.duplicate()
  opts.stages[levelName].color = randfrom(1, 11)
  file.write(path.join(fullDirPath, levelName + ".sds"), '', false)
  sds.saveDataToFile(path.join(fullDirPath, "options.sds"), opts)

func createNewMapFolder() -> Variant:
  var foldername: String = await prompt("Enter the name of the map", PromptTypes.string, "New map")
  var startLevel: String = await prompt("Enter the name of the first level:", PromptTypes.string, "hub")
  var fullDirPath := path.parsePath(path.join("res://maps/", foldername))
  if DirAccess.dir_exists_absolute(fullDirPath):
    await prompt("Folder already exists!")
    return
  DirAccess.make_dir_absolute(fullDirPath)
  sds.saveDataToFile(path.join(fullDirPath, "options.sds"),
    {
      "start": startLevel,
      "author": await prompt(
        "Enter your name",
        PromptTypes.string,
        "",
      ),
      "description": await prompt(
        "Enter a description of the map:",
        PromptTypes.string,
        "",
      ),
      "version": VERSION,
      "stages": {
      }
    }
  )
  await createNewLevelFile(foldername, startLevel)
  return foldername

const defaultLevelSettings = {
  "color": 1,
  "changeSpeedOnSlopes": false
}

func currentLevelSettings(key: Variant = null) -> Variant:
  if key:
    var data: Variant = levelOpts.stages[currentLevel().name][key] \
    if key in levelOpts.stages[currentLevel().name] else \
    defaultLevelSettings[key]
    return data
  return levelOpts.stages[currentLevel().name]

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
  DirAccess.make_dir_recursive_absolute(path.parsePath("res://maps/"))
  DirAccess.make_dir_recursive_absolute(path.parsePath("res://downloaded maps/"))
  DirAccess.make_dir_recursive_absolute(path.parsePath("res://saves/"))
  DirAccess.make_dir_recursive_absolute(path.parsePath("res://exports/"))
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
  var pid = int(file.read(path.parsePath("res://process"), false, "0"))
  log.pp("FILEPID", pid)
  log.pp("MYPID", OS.get_process_id())
  getProcess(OS.get_process_id())
  if getProcess(pid) and (('vex' in getProcess(pid)) or ("Godot" in getProcess(pid))):
    sds.saveDataToFile(path.parsePath("res://filesToOpen"), OS.get_cmdline_args() as Array)
    DirAccess.remove_absolute(path.parsePath("res://process"))
    quitGame()
  else:
    file.write(path.parsePath("res://process"), str(OS.get_process_id()), false)
    tryAndGetMapZipsFromArr(OS.get_cmdline_args())

func _notification(what):
  if what == NOTIFICATION_WM_CLOSE_REQUEST:
    quitGame()
    
func quitGame():
  if OS.get_process_id() == int(file.read(path.parsePath("res://process"), false)):
    DirAccess.remove_absolute(path.parsePath("res://process"))
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

func tryAndLoadMapFromZip(from, to):
  var reader = ZIPReader.new()
  var err = reader.open(from)
  if err:
    log.warn(from, err)
    return

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
  log.warn(files, tempFiles)
  if "options.sds" not in tempFiles:
    log.err("not a valid map file", from, to, files)
    return
  log.pp("loading map from", from, "to", to)
  DirAccess.make_dir_recursive_absolute(to)
  var root_dir = DirAccess.open(to)
  for file_path in files:
    var outpath = file_path
    if allInSameDir:
      outpath = regReplace(file_path, r"^[^/\\]+[/\\]", '')
    # If the current entry is a directory.
    if file_path.ends_with("/"):
      root_dir.make_dir_recursive(outpath)
      continue

    # Write file contents, creating folders automatically when needed.
    # Not all ZIP archives are strictly ordered, so we need to do this in case
    # the file entry comes before the folder entry.
    root_dir.make_dir_recursive(root_dir.get_current_dir().path_join(outpath).get_base_dir())
    var file = FileAccess.open(root_dir.get_current_dir().path_join(outpath), FileAccess.WRITE)
    var buffer = reader.read_file(file_path)
    file.store_buffer(buffer)
  return true

func tryAndGetMapZipsFromArr(args):
  var mapFound = false
  for p in args:
    if FileAccess.file_exists(p):
      log.pp("AKSJDHSADKJHDHJDSKDSHKJDSA", p)
      if !('.' in p and ('/' in p or '\\' in p)): return
      # add the intended folder to the end of the path to force it to go into the correct folder
      var moveto = path.parsePath("res://maps/" + regMatch(p, r"[/\\]([^/\\]+)\.[^/\\]+$")[1])
      if tryAndLoadMapFromZip(p, moveto):
        mapFound = true
  if mapFound and get_tree().current_scene.name == "main menu":
    await wait(1000)
    get_tree().reload_current_scene.call_deferred()
    DisplayServer.window_move_to_foreground()
  log.pp("get_tree().current_scene", get_tree().current_scene.name)

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

func openPathInExplorer(p: String):
  log.pp(p)
  OS.create_process("explorer", PackedStringArray([
    '"' + (
      ProjectSettings.globalize_path(p)
      if OS.has_feature("editor") else
      global.path.parsePath(p)
    ).replace("/", "\\")
    + '"'
  ]))

var ui: CanvasLayer

func copyDir(source: String, destination: String):
  DirAccess.make_dir_recursive_absolute(destination)

  var source_dir = DirAccess.open(source);

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

var blockNames: Array = [
  "basic", # 1
  "single spike", # 1
  "10x spike", # 1
  # "invisible", # 0
  "updown", # 1
  "downup", # 1
  "water", # 1
  "solar", # 1
  "slope", # 1
  "pushable box", # 1
  "microwave", # 1
  "locked box", # 1
  "glass", # 1
  "leftright", # 1
  "falling", # 1
  "bouncy", # 1
  "spark counterClockwise", # 1
  "spark clockwise", # 1
  "inner level", # .5
  "goal", # 1
  "buzsaw", # .9
  "bouncing buzsaw", # .9
  "cannon", # .2
  "checkpoint", # .8
  "closing spikes", # 1
  "Gravity Down Lever", # 1
  "Gravity up Lever", # 1
  "speed Up Lever", # 0
  "growing buzsaw", # 0
  "key", # 1
  # "laser", # 0
  "light switch", # .9
  "pole", # 0
  "Pole Quadrant", # 0
  "Pulley", # 1
  "Quadrant", # 1
  "Rotating Buzzsaw", # 1
  "Scythe", # 1
  # "shurikan Spawner", # .1
  "star", # .8
  # "targeting laser", # 0
  # "ice", # 0
  "death boundary", # 1
  "block death boundary", # 1
  # "basic - nowj", # -.5
  "nowj", # 1
  "falling spike", # 1
  # "quad falling spikes" # 0
  "portal", # 1
  # "path", # .3
]

var lastPortal: Node2D = null

var defaultBlockOpts: Dictionary={}