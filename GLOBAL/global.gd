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

func _process(delta):
  if global.openMsgBoxCount: return
  if timer.started:
    timer.time += delta
  for i: Array in wait_until_wait_list:
    if has_user_signal(i[0]) and i[1] && i[1].is_valid() && i[1].call():
      Signal(self, i[0]).emit()
      remove_user_signal(i[0])
  localProcess(delta)

var openMsgBoxCount = 0

var promptPromise

func prompt(msg, default=null, type="string"):
  if openMsgBoxCount:
    while openMsgBoxCount:
      await wait(10)
  openMsgBoxCount += 1

  var promptCanvas = preload("res://GLOBAL/prompt.tscn").instantiate()
  level.add_child(promptCanvas)
  promptCanvas.get_node("ColorRect").size = DisplayServer.window_get_size()
  promptCanvas.get_node("ColorRect/CenterContainer").size = DisplayServer.window_get_size()
  promptCanvas.promptText.text = msg

  promptCanvas.numEdit.visible = false
  promptCanvas.strEdit.visible = false
  # log.pp(type)
  match type:
    "int":
      promptCanvas.numEdit.value = 0 if default == null else default
      promptCanvas.numEdit.step = 1
      promptCanvas.numEdit.rounded = true
      promptCanvas.numEdit.get_line_edit().connect("text_submitted", _on_submit)
      promptCanvas.numEdit.visible = true
      promptCanvas.numEdit.get_line_edit().grab_focus()
    "bool":
      pass
      # promptCanvas.boolEdit.checked = default
    "string":
      promptCanvas.strEdit.text = '' if default == null else default
      promptCanvas.strEdit.connect("text_submitted", _on_submit)
      promptCanvas.strEdit.visible = true
      promptCanvas.strEdit.grab_focus()
    "float":
      promptCanvas.numEdit.value = 0.0 if default == null else default
      promptCanvas.numEdit.rounded = false
      promptCanvas.numEdit.step = .1
      promptCanvas.numEdit.get_line_edit().connect("text_submitted", _on_submit)
      promptCanvas.numEdit.visible = true
      promptCanvas.numEdit.get_line_edit().grab_focus()

  promptCanvas.btnOk.connect("pressed", _on_submit)
  promptCanvas.btnCancel.connect("pressed", _on_cancel)
  promptCanvas.visible = true
  promptPromise = Promise.new()
  var confirmed = await promptPromise.wait()
  var val
  match type:
    "bool": val = confirmed
    "string": val = promptCanvas.strEdit.text if confirmed else default
    "float": val = float(promptCanvas.numEdit.value) if confirmed else default
    "int": val = int(promptCanvas.numEdit.value) if confirmed else default

  promptCanvas.queue_free.call_deferred()
  return val

func _on_submit(text=null):
  openMsgBoxCount -= 1
  promptPromise.resolve(true)
func _on_cancel():
  openMsgBoxCount -= 1
  promptPromise.resolve(false)

class cache:
  var cache = {}
  var _data = {}
  func _init() -> void:
    pass
  func __has(thing):
    if "lastinp" in self._data:
      log.err("lastinp should not exist", self)
      return
    self._data.lastinp = thing
    return thing in self.cache
  func __get():
    if "lastinp" not in self._data:
      log.err("No lastinp", self)
      return
    var val = self.cache[self._data.lastinp]
    self._data.erase("lastinp")
    return val
  func __set(value):
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

var regMatchCache = cache.new()
func regMatch(str: String, reg: String):
  if regMatchCache.__has([reg, str]):
    return regMatchCache.__get()
  var reg2 = RegEx.create_from_string(reg)
  var res := reg2.search(str)
  if not res: return res
  var out := []
  for i in range(0, res.get_group_count() + 1):
    out.push_back(res.get_string(i))
  return regMatchCache.__set(out)

var regMatchAllCache = cache.new()
func regMatchAll(str: String, reg: String):
  if regMatchAllCache.__has([reg, str]):
    return regMatchAllCache.__get()
  var reg2 = RegEx.new()
  reg2.compile(reg)
  var res := reg2.search_all(str)
  var out := []
  for j in len(res):
    out.append([])
    for i in range(0, res[j].get_group_count() + 1):
      out[len(out) - 1].push_back(res[j].get_string(i))
  return regMatchAllCache.__set(out)

var regReplaceCache = cache.new()
func regReplace(str: String, reg: String, with: String, all:=true) -> String:
  if regReplaceCache.__has([reg, str, with, all]):
    return regReplaceCache.__get()
  var reg2 = RegEx.new()
  reg2.compile(reg)
  return regReplaceCache.__set(reg2.sub(str, with, all))

# const filepath = {
# }

func same(x: Variant, y: Variant) -> bool:
  return typeof(x) == typeof(y) && x == y

func join(joiner="", a="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", s="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", d="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", f="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", g="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", h="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", j="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", k="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", l="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", z="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", x="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", c="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", v="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", b="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", n="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", m="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", q="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", w="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", e="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", r="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", t="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", y="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", u="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", i="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", o="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", p="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD"):
  var temparr = [a, s, d, f, g, h, j, k, l, z, x, c, v, b, n, m, q, w, e, r, t, y, u, i, o, p]
  temparr = temparr.filter(func(e):
    return !same(e, "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD")
    )
  return joiner.join(temparr)

func randstr(length=10, fromchars="qwertyuiopasdfghjklzxcvbnm1234567890~!@#$%^&*()_+-={ }[']\\|;:\",.<>/?`"):
  var s = ''
  for i in range(length):
    s += (fromchars[global.randfrom(0, len(fromchars) - 1)])
  return s

var wait_until_wait_list = []
func waituntil(cb):
  var sig = "wait until signal - " + randstr(30)
  add_user_signal(sig)
  wait_until_wait_list.append([sig, cb])
  return Signal(self, sig)

# class link:
#   static var links = []
#   static func create(varname, node, cb=func(a):
#     return a, prop="text"):
#     global.link.links.append({"node": node, "varname": varname, "prop": prop, "val": null, "cb": cb})
#   # s=set because error when name is set
#   static func s(varname, val):
#     for l in global.link.links:
#       if l.node == varname:
#         l.val = val
#         l.node[l.prop] = l.cb(val)

class lableformat:
  static var lableformats = {}
  static func create(name, label, format):
    global.lableformat.lableformats[name] = {"text": format, "node": label}
  static func update(name, newtext: Dictionary):
    var keys = newtext.keys();
    var temp = global.lableformat.lableformats[name]
    var node = temp.node
    var text = temp.text
    for key in keys:
      var val = newtext[key]
      text = text.replace("{" + str(key) + "}", str(val))
    node.text = text

  # for link in global.link.links:
  #   if link.node.is_inside_tree() and link.node.is_node_ready():
  #     link.node[link.prop] = link.cb.call(link.val)
class timer:
  static var time: float = 0
  static var started: bool = false
  static func reset():
    timer.time = 0
  static func format(temptime="DJKASDHjkaDHJkashdjkAS") -> String:
    var time: float = timer.time if global.same(temptime, "DJKASDHjkaDHJkashdjkAS") else float(temptime)
    var minutes: float = time / 60
    var seconds: float = fmod(time, 60)
    var milliseconds: float = fmod(time, 1) * 100
    return "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
  static func stop():
    timer.started = false
  static func start():
    timer.started = true

func debuguistart() -> void:
  event.trigger("debugui start")

func debuguiclear():
  if event.triggers.has("debugui clear"):
    event.trigger("debugui clear")

func debuguiadd(name: String, val: String) -> void:
  if event.triggers.has("debugui add"):
    event.trigger("debugui add", name, val)

class path:
  static func parsePath(p: String) -> String:
    # log.pp(1, p)
    if !OS.has_feature("editor"):
      return global.regReplace(p, 'res://', OS.get_executable_path().get_base_dir() + '/')
    return p
  static func join(path1: String, path2:="", path3:="", path4:="") -> String:
    var fullPath := path1
    if len(path2):
      var slash = 0
      if global.ends_with(fullPath, "/"):
        slash += 1
      if global.starts_with(path2, "/"):
        slash += 1
      match slash:
        0: fullPath += "/" + path2
        1: fullPath += path2
        2: fullPath += global.regReplace(path2, '^/', '')
    if len(path3):
      var slash = 0
      if global.ends_with(fullPath, "/"):
        slash += 1
      if global.starts_with(path3, "/"):
        slash += 1
      match slash:
        0: fullPath += "/" + path3
        1: fullPath += path3
        2: fullPath += global.regReplace(path3, '^/', '')
    if len(path4):
      var slash = 0
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
  static func save(tile_map: TileMap):
    var layers: int = tile_map.get_layers_count()
    var tile_map_layers = []
    tile_map_layers.resize(layers)
    for layer in layers:
      tile_map_layers[layer] = tile_map.get("layer_%s/tile_data" % layer)
    return tile_map_layers
  static func load(tile_map: TileMap, data: Array) -> void:
    for layer in data.size():
      var tiles = data[layer]
      tile_map.set('layer_%s/tile_data' % layer, tiles)

class file:
  static func write(p: String, text: Variant, asjson:=true):
    # p = path.parsePath(p)
    FileAccess.open(p, FileAccess.WRITE_READ).store_string(JSON.stringify(text, "  " if OS.has_feature("editor") else '') if asjson else text)
  static func isFile(p: String) -> bool:
    return !!FileAccess.open(p, FileAccess.READ)
  static func read(p: String, asjson:=true, default:=''):
    # p = path.parsePath(p)
    var f = FileAccess.open(p, FileAccess.READ)
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
  static func getcount(array, count):
    var newarr = []
    for i in range(count):
      if array.size() == 0: return null
      newarr.append(array[0])
      array.remove_at(0)
    return newarr
class event:
  static var triggers: Dictionary = {}
  static func trigger(msg: String, data1="AHDSJKHDASJK", data2="AHDSJKHDASJK", data3="AHDSJKHDASJK") -> void:
    if !msg in triggers:
      log.error('no triggers set for call', msg)
      return
    for cb in triggers[msg]:
      if cb != null and cb.is_valid():
        var default = "AHDSJKHDASJK"
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

class InputManager:
  func _init(_init_key_names):
    self.key_names = _init_key_names
    for key in self._data.key_names.keys():
      self.unpress(key)

    _update_key_press_states()
  var trypress = {}
  var key_names = {}
  var KEY_MAX_BUFFER: int = 15

  func pressed(key) -> int:
    return !!trypress[key].pressed

  func just_pressed(key) -> int:
    var ret = !!trypress[key].just_pressed
    if ret:
      trypress[key].just_pressed = 0
    return ret

  func just_released(key) -> int:
    return Input.is_action_just_released(key_names[key])
  func compare(neg, pos) -> int:
    var input_dir = 0
    if self.pressed(neg) == self.pressed(pos):
      input_dir = 0
    elif self.pressed(neg) and not self.pressed(pos):
      input_dir = -1
    elif self.pressed(pos):
      input_dir = 1
    return input_dir
  func unpress(key):
    trypress[key] = {
      "pressed": 0,
      "just_pressed": 0,
    }
  func press(key) -> void:
    trypress[key] = {
      "pressed": KEY_MAX_BUFFER,
      "just_pressed": KEY_MAX_BUFFER,
    }
  func _update_key_press_states() -> void:
    for key in self._data.key_names.keys():
      if !key_names[key]: continue
      if Input.is_action_just_pressed(key_names[key]):
        trypress[key].just_pressed = KEY_MAX_BUFFER
      elif trypress[key].just_pressed:
        trypress[key].just_pressed -= 1

      if Input.is_action_pressed(key_names[key]):
        trypress[key].pressed = 1
      else:
        unpress(key)

func wait(time: float = 0, ignore_time_scale: bool = false):
  if time == 0:
    return await get_tree().process_frame
  return await get_tree().create_timer(time / 1000.0, true, false, ignore_time_scale).timeout

func starts_with(x: String, y: String) -> bool:
  return x.substr(0, len(y)) == y
func ends_with(x: String, y: String) -> bool:
  return x.substr(len(x) - len(y)) == y

func randfrom(min: float, max: float) -> float:
  # if global.same(max, "unset"):
  #   return min[randfrom(0, len(min) - 1)]
  return int(randf() * (max - min + 1) + min)

func rerange(val: Variant, low1: Variant, high1: Variant, low2: Variant, high2: Variant):
  if typeof(val) == typeof(0) or typeof(val) == typeof(0.0):
    val = float(val)
    low1 = float(low1)
    high1 = float(high1)
  if typeof(low2) == typeof(0) or typeof(low2) == typeof(0.0):
    low2 = float(low2)
    high2 = float(high2)
  return ((val - low1) / (high1 - low1)) * (high2 - low2) + low2

var tick = 0
var stopTicking = false
func _physics_process(delta: float) -> void:
  if openMsgBoxCount: return
  if stopTicking: return
  tick += delta

# local game only data

var player: Node
var level: Node

var hoveredBlocks: Array = []
var selectedBlock: Node = null
var selectedBlockOffset: Vector2
var editorInScaleMode := false
var editorInRotateMode := false

var scaleOnTopSide := true
var scaleOnBottomSide := false
var scaleOnRightSide := false
var scaleOnLeftSide := false
var showEditorUi := false
var selectedBrush: Node
var justPaintedBlock: Node = null
const gridSize = 25 / 5.0

func selectBlock():
  # select the top hovered block
  var block = hoveredBlocks[0]
  hoveredBlocks.pop_front.call_deferred()
  selectedBlock = block
  var bpos: Vector2 = block.position
  var mpos: Vector2 = player.get_global_mouse_position()
  selectedBlockOffset = Vector2(bpos.x - mpos.x, bpos.y - mpos.y)
  var sizeInPx = selectedBlock.ghost.texture.get_size() * selectedBlock.scale * selectedBlock.ghost.scale
  selectedBlockOffset = round((selectedBlockOffset) / gridSize) * gridSize + (sizeInPx / 2)

var rotresetBlock = null

func localProcess(delta: float) -> void:
  if not player: return
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
    var mpos = selectedBlock.get_global_mouse_position() if selectedBlock else selectedBrush.get_global_mouse_position()

    player.moving = 2

    # when trying to rotate blocks
    if editorInRotateMode && selectedBlock.is_in_group("EDITOR_OPTION_rotate"):
      selectedBlock.look_at(mpos)
      selectedBlock.rotation_degrees = round(selectedBlock.rotation_degrees / 15) * 15
      setBlockStartPos(selectedBlock)
    # when trying to scale blocks
    elif editorInScaleMode && selectedBlock.is_in_group("EDITOR_OPTION_scale"):
      var sizeInPx = selectedBlock.ghost.texture.get_size() * selectedBlock.scale * selectedBlock.ghost.scale

      # get the edge position in px
      var bottom_edge = selectedBlock.global_position.y + sizeInPx.y / 2
      var top_edge = selectedBlock.global_position.y - sizeInPx.y / 2
      var right_edge = selectedBlock.global_position.x + sizeInPx.x / 2
      var left_edge = selectedBlock.global_position.x - sizeInPx.x / 2

      # scale on the selected sides
      if scaleOnTopSide:
        var mouseDIstInPx = (top_edge - mpos.y)
        mouseDIstInPx = round(mouseDIstInPx / (gridSize * 1)) * (gridSize * 1)
        selectedBlock.scale.y = (selectedBlock.scale.y + (mouseDIstInPx / sizeInPx.y * selectedBlock.scale.y))
        selectedBlock.global_position.y = selectedBlock.global_position.y - (mouseDIstInPx / 2)
      elif scaleOnBottomSide:
        var mouseDIstInPx = (mpos.y - bottom_edge)
        mouseDIstInPx = round(mouseDIstInPx / (gridSize * 1)) * (gridSize * 1)
        selectedBlock.scale.y = (selectedBlock.scale.y + (mouseDIstInPx / sizeInPx.y * selectedBlock.scale.y))
        selectedBlock.global_position.y = selectedBlock.global_position.y + (mouseDIstInPx / 2)
      if scaleOnLeftSide:
        var mouseDIstInPx = (left_edge - mpos.x)
        mouseDIstInPx = round(mouseDIstInPx / (gridSize * 1)) * (gridSize * 1)
        selectedBlock.scale.x = (selectedBlock.scale.x + (mouseDIstInPx / sizeInPx.x * selectedBlock.scale.x))
        selectedBlock.global_position.x = selectedBlock.global_position.x - (mouseDIstInPx / 2)
      elif scaleOnRightSide:
        var mouseDIstInPx = (mpos.x - right_edge)
        mouseDIstInPx = round(mouseDIstInPx / (gridSize * 1)) * (gridSize * 1)
        selectedBlock.scale.x = (selectedBlock.scale.x + (mouseDIstInPx / sizeInPx.x * selectedBlock.scale.x))
        selectedBlock.global_position.x = selectedBlock.global_position.x + (mouseDIstInPx / 2)

      # make block no larger than 250% and no less than 10% default size
      selectedBlock.scale.x = clamp(selectedBlock.scale.x, 0.1 / 7.0, 25.0 / 7.0)
      selectedBlock.scale.y = clamp(selectedBlock.scale.y, 0.1 / 7.0, 25.0 / 7.0)
      global.showEditorUi = true
      selectedBlock.self_modulate.a = 0

      setBlockStartPos(selectedBlock)
      selectedBlock.respawn()
    else:
      # if trying to create new block
      if justPaintedBlock:
        selectedBlock = justPaintedBlock
        selectedBlockOffset = Vector2.ZERO
        log.pp(selectedBlock.ghost, selectedBlock.id)
        var sizeInPx = selectedBlock.ghost.texture.get_size() * selectedBlock.scale * selectedBlock.ghost.scale
        selectedBlockOffset = round((selectedBlockOffset) / gridSize) * gridSize + (sizeInPx / 2)
      # if you have clicked on a block in the editor bar
      if not justPaintedBlock and selectedBrush and selectedBrush.selected == 2:
        # create a new block
        justPaintedBlock = load("res://scenes/blocks/" + selectedBrush.blockName + "/main.tscn").instantiate()
        justPaintedBlock.id = blockNames[selectedBrush.id]
        justPaintedBlock.scale = Vector2(1, 1) / 7
        # justPaintedBlock.scale = selectedBrush.normalScale
        # justPaintedBlock.startScale = selectedBrush.normalScale
        justPaintedBlock.global_position = mpos
        justPaintedBlock.rotation_degrees = 0
        setBlockStartPos(justPaintedBlock)
        level.get_node("blocks").add_child(justPaintedBlock)
        # after creating the block recall this to update the position
        localProcess(0)

      # if trying to move a block
      else:
        # get block size in pixels
        var sizeInPx = selectedBlock.ghost.texture.get_size() * selectedBlock.scale * selectedBlock.ghost.scale

        # check if block scale is odd
        var isYOnOddScale = str(int(selectedBlock.scale.y * 700))
        isYOnOddScale = isYOnOddScale[len(isYOnOddScale) - 1] == '5'
        var isXOnOddScale = str(int(selectedBlock.scale.x * 700))
        isXOnOddScale = isXOnOddScale[len(isXOnOddScale) - 1] == '5'

        # offset the block on the sides that are odd to make it align with the grid
        var offset = Vector2((gridSize / 2.0) if isXOnOddScale else 0.0, (gridSize / 2.0) if isYOnOddScale else 0.0)
        mpos = round((mpos - offset) / gridSize) * gridSize

        selectedBlock.global_position = round(mpos + selectedBlockOffset - (sizeInPx / 2))
        if isYOnOddScale or isXOnOddScale:
          selectedBlock.global_position += offset
        setBlockStartPos(selectedBlock)
        # if selectedBlock.name == "player":
        #   selectedBlock.get_node("CharacterBody2D").moving = 2
        selectedBlock.respawn()
func setBlockStartPos(block: Node):
  block.startPosition = block.position
  if block != rotresetBlock:
    block.startRotation_degrees = block.rotation_degrees
  block.startScale = block.scale

var hitboxesShown = false

func _input(event: InputEvent) -> void:
  if !InputMap.has_action("editor_select"): return
  if Input.is_action_just_released("editor_select"):
    if selectedBlock:
      selectedBlock.respawn()
      selectedBlock = null
      # selectedBlock._ready.call(false)
  if Input.is_action_just_pressed("editor_select"):
    if selectedBlock:
      selectedBlock.respawn()
  if Input.is_action_just_released("down"):
    if player and mainLevelName:
      savePlayerLevelData()
      # selectedBlock._ready.call(false)

  # dont update editor scale mode if clicking
  if !Input.is_action_pressed("editor_select"):
    editorInScaleMode = Input.is_action_pressed("editor_scale")
  if !Input.is_action_pressed("editor_select") and not editorInScaleMode:
    editorInRotateMode = Input.is_action_pressed("editor_rotate")
  if Input.is_action_just_pressed("save"):
    level.save()
  if Input.is_action_just_pressed("editor_delete"):
    if !selectedBlock: return
    hoveredBlocks.erase(selectedBlock)
    selectedBlock.queue_free.call_deferred()
    selectedBlock = null
  if Input.is_action_just_pressed("reload_map"):
    loadLevelPack(mainLevelName, true)
  if Input.is_action_just_pressed("toggle_hitboxes"):
    hitboxesShown = !hitboxesShown
    get_tree().set_debug_collisions_hint(hitboxesShown)
    showEditorUi = !showEditorUi
    await wait(1)
    showEditorUi = !showEditorUi
  if Input.is_action_just_pressed("quit"):
    get_tree().quit()
  if Input.is_action_just_pressed("load"):
    get_tree().change_scene_to_file.call_deferred("res://scenes/main menu/main_menu.tscn")
    Input.mouse_mode = Input.MOUSE_MODE_CONFINED

var levelFolderPath
var loadedLevels
var mainLevelName
var beatLevels
var levelColor = 2
var levelOpts

func starFound():
  currentLevel().foundStar = true

func loadInnerLevel(innerLevel):
  currentLevel().spawnPoint = player.global_position - player.get_parent().global_position
  global.loadedLevels.append({"name": innerLevel, "spawnPoint": Vector2.ZERO, 'foundStar': false})
  if currentLevel().name not in levelOpts.stages:
    log.err("ADD SETTINGS for " + currentLevel().name + " to options file")
  levelColor = int(levelOpts.stages[currentLevel().name].color)
  await wait()
  level.loadLevel(innerLevel)
  player.die(0, true)
  player.deathPosition = player.lastSpawnPoint
  log.pp(loadedLevels, beatLevels)

func win():
  beatLevels.append(loadedLevels.pop_back())
  if len(loadedLevels) == 0:
    log.pp("PLAYER WINS!!!")
    Engine.time_scale = 0
    return
  # log.pp(currentLevel().spawnPoint, currentLevel())
  await wait()
  level.loadLevel(currentLevel().name)
  log.pp(loadedLevels, beatLevels)
  player.lastSpawnPoint = currentLevel().spawnPoint
  player.die(0, false)
  player.deathPosition = player.lastSpawnPoint

var savingPlaterLevelData := false

func savePlayerLevelData():
  if savingPlaterLevelData: return
  log.pp("asadasdasdasdasadsasd")
  savingPlaterLevelData = true
  var saveData = file.read(path.parsePath("res://saves/saves.json"))
  var levels = {}
  for l in loadedLevels:
    levels[l.name] = l
  for l in beatLevels:
    levels[l.name] = l
  var playerDelogPosition = player.position
  saveData[mainLevelName] = {
    "playerDelogPosition": [playerDelogPosition.x, playerDelogPosition.y],
    "lastSpawnPoint": [player.lastSpawnPoint.x, player.lastSpawnPoint.y],
    "loadedLevels": loadedLevels.map(func(e):
      var ee=JSON.parse_string(JSON.stringify(e))
      ee.spawnPoint=[e.spawnPoint.x, e.spawnPoint.y]
      return ee),
    "beatLevels": beatLevels.map(func(e):
      var ee=JSON.parse_string(JSON.stringify(e))
      ee.spawnPoint=[e.spawnPoint.x, e.spawnPoint.y]
      return ee),
    "levels": levels
  }
  file.write(path.parsePath("res://saves/saves.json"), saveData)
  await wait(1000)
  savingPlaterLevelData = false

func loadLevelPack(levelPackName, loadFromSave):
  log.pp("loadFromSave", loadFromSave)
  var saveData = file.read(path.parsePath("res://saves/saves.json"))
  if levelPackName in saveData:
    saveData = saveData[levelPackName]
  else:
    saveData = null
  # save the name globaly
  mainLevelName = levelPackName
  Engine.time_scale = 1
  log.pp("Loading Level Pack:", levelPackName)
  levelFolderPath = path.join('res://levelcodes/', levelPackName)
  var levelPackInfo = loadLevelPackInfo(levelPackName)
  if !levelPackInfo: return
  var startFile = path.join(levelFolderPath, levelPackInfo['start'])
  if !file.isFile(startFile):
    log.err("LEVEL NOT FOUND!", startFile)
    return
  levelOpts = levelPackInfo

  if loadFromSave and saveData:
    loadedLevels = saveData.loadedLevels.map(func(e):
      e.spawnPoint=Vector2(e.spawnPoint[0], e.spawnPoint[1])
      return e)
    beatLevels = saveData.beatLevels.map(func(e):
      e.spawnPoint=Vector2(e.spawnPoint[0], e.spawnPoint[1])
      return e)
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
  level.loadLevel(global.currentLevel().name)
  if loadFromSave and saveData:
    await wait()
    player.die(0, false)
    player.deathPosition = player.lastSpawnPoint
    player.goto(Vector2(saveData.playerDelogPosition[0], saveData.playerDelogPosition[1]))
    # player.goto.call_deferred(Vector2(saveData.playerDelogPosition[0], saveData.playerDelogPosition[1]))
    player.lastSpawnPoint = Vector2(saveData.lastSpawnPoint[0], saveData.lastSpawnPoint[1])
    global.tick = 0

func currentLevel():
  return loadedLevels[len(loadedLevels) - 1]

func loadLevelPackInfo(levelPackName):
  var options = file.read(path.join('res://levelcodes/', levelPackName, "/options"))
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

var useropts = {
  # "allowCustomColors": true,
  # "blockPickerBlockSize": 50
}

var blockNames = [
  "basic",
  "single spike",
  "10x spike",
  "invisible",
  "updown",
  "downup",
  "water",
  "solar",
  "slope",
  "pushable box",
  "microwave",
  "locked box",
  "ice",
  "leftright",
  "falling",
  "bouncy",
  "spark",
  "inner level",
  "goal",
  "buzsaw",
  "bouncing buzsaw",
  "cannon",
  "checkpoint",
  "closing spikes",
  "Gravity Down Lever",
  "Gravity up Lever",
  "growing buzsaw",
  "key",
  "laser",
  "light switch",
  "pole",
  "Pole Quadrant",
  "Pulley",
  "Quadrant",
  "Rotating Buzzsaw",
  "Scythe",
  "shurikan Spawner",
  "speed Up Lever",
  "star",
  "targeting laser",
]

func _ready() -> void:
  get_tree().set_debug_collisions_hint(hitboxesShown)

var checkpoints = []

func animate(speed: int, steps: Array[Dictionary]):
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
  var currentTime = fmod(global.tick * speed, steps[len(steps) - 1].until)
  var newOffset
  var prevTime = 0
  for i in range(0, len(steps)):
    if currentTime < steps[i].until:
      newOffset = global.rerange(currentTime, prevTime, steps[i].until, steps[i].from, steps[i].to)
      break
    else:
      prevTime = steps[i].until
  return newOffset
