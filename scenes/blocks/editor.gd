@icon("editorIcon.png")
class_name EditorBlock
extends Node2D
## sprite to use for the ghost
@export var ghostIconNode: Sprite2D
# @export var mainColor: Color

## sprite to show in the editor bar
@export var editorBarIcon: Texture2D:
  get():
    if global.player and editorBarIconUsesLevelColor:
      return load(editorBarIcon.resource_path \
      .replace("/editorBar1.png", '/editorBar' + str(global.currentLevelSettings("color")) + '.png') \
      .replace("/1.png", '/' + str(global.currentLevelSettings("color")) + '.png')
      )
    return editorBarIcon
## sprite to show in the editor bar
@export var editorBarIconUsesLevelColor: bool = false
## sprites to disable when node disabled
@export var collisionShapes: Array[CollisionShape2D]
## sprites to hide when node disabled
@export var hidableSprites: Array[Node]
## sends some events to this node
@export var cloneEventsHere: Array[Node]
## the node that lastMovementStep should be calculated from
@export var thingThatMoves: Node2D
@export var ghostFollowNode: Node2D = self
@export var mouseRotationOffset = 90
@export_group("misc")
## no warnings when missing unrequired nodes
@export var ignoreMissingNodes := false
@export var oddScaleOffsetForce: Dictionary[String, boolOrNull] = {"x": boolOrNull.unset, 'y': boolOrNull.unset}

## if false scale is 1/7
@export var normalScale := false
## if true don't disable physics process when node is disabled
@export var dontDisablePhysicsProcess := false
## disables editor features suchas moving, scaling, selecting
@export var EDITOR_IGNORE: bool = false
## dont't stop sending collisions during player respawn
@export var SEND_COLLISIONS_DOURING_PLAYER_RESPAWN: bool = false
## prevents the node from being saved with the level
@export var DONT_SAVE: bool = false
## don't call __enable when the node respawns
@export var DONT_ENABLE_ON_RESPAWN: bool = false
## prevents the node from being moved by respawning
@export var DONT_MOVE_ON_RESPAWN: bool = false
## prevents the color option from appearing in this blocks rclick menu
@export var NO_CUSTOM_COLOR_IN_MENU: bool = false
## disables the rclick menu for this block
@export var NO_RCLICK_MENU: bool = false
# @export var REMOVE_ON_PLAYER_DEATH: bool = false
@export var REMOVE_ON_RESPAWN: bool = false
@export var KILL_AFTER_TIME: int = 0
## prevents selecting this block - selection box still appears, need to fix later
# @export var NO_SELECTING: bool = false

## prevents selecting this block - selection box still appears, need to fix later

@export var EDITOR_OPTION_scale: bool = false
@export var EDITOR_OPTION_rotate: bool = false
@export var canAttachToThings: bool = false
@export var canAttachToPaths: bool = false

var loadDefaultData: bool = true
var isBeingPlaced := false

# var hasBeenExploded := false:
#   set(val):
#     hasBeenExploded = val
#     if hasBeenExploded:
#       __disable.call_deferred()

var intendedPositionOfThingThatMoves := Vector2.ZERO

func moveTo(pos: Vector2):
  thingThatMoves.global_position += pos - intendedPositionOfThingThatMoves
  intendedPositionOfThingThatMoves += pos - intendedPositionOfThingThatMoves

enum boolOrNull {
  _false = -1,
  _true = 1,
  _null = 0,
  no = -1,
  yes = 1,
  unset = 0,
}

func updateSelectedOptionsUi() -> void:
  if self == global.ui.blockMenu.lastShownBlock:
    global.ui.blockMenu.updateBlockMenuValues()

var defaultSizeInPx: Vector2
var sizeInPx: Vector2:
  get():
    return defaultSizeInPx * startScale
  set(value):
    defaultSizeInPx = value / startScale

var root = self
var _DISABLED := false
var isHovered := false
var isChildOfCustomBlock = false
var id: String
var startPosition: Vector2
var startRotation_degrees: float:
  set(val):
    startRotation_degrees = fmod(val, 360)
var startScale: Vector2 = Vector2(1, 1)
var ghost: Node2D
## distance moved in last frame
var lastMovementStep: Vector2
var respawning := 0
## options in the rclick menu and their type
var blockOptions: Dictionary[String, Variant]
## options in the rclick menu along with their selected state
var selectedOptions := {}
## options in the rclick menu
# var blockOptionsArray := []
## used for following blocks
var attach_children: Array[EditorBlock] = []:
  get():
    attach_children.assign(attach_children.filter(global.isAlive))
    return attach_children
## used for following blocks
var attach_parents: Array[EditorBlock] = []:
  get():
    attach_parents.assign(attach_parents.filter(global.isAlive))
    return attach_parents
## when being moved in the editor
var isBeingMoved := false
## the positional offset caused by setting following to false in attach detector
var unusedOffset = Vector2.ZERO

# var currentPath: PathFollow2D

# -------------------------------------------
func generateBlockOpts(): pass
## overite this to return properties to save
func onSave() -> Array:
  return []
# -------------------------------------------
func onPathMove(dist): pass
func onEditorRotate(): pass
func onEditorMoveEnded(): pass
func onEditorRotateEnd(): pass
func onEditorDelete(): pass
# -------------------------------------------
## overite this to receive event when data for this block is loaded
func onDataLoaded() -> void: pass
## overite this to receive event when data for all blocks loaded
func onAllDataLoaded() -> void: pass
# -------------------------------------------
func on_respawn(): pass
func on_ready(): pass
func on_body_entered(body: Node2D): pass
func on_body_exited(body: Node2D): pass
func on_physics_process(delta: float) -> void: pass
func on_process(delta: float): pass
# -------------------------------------------

func _on_mouse_entered() -> void:
  isHovered = true

func _on_mouse_exited() -> void:
  isHovered = false

func onEditorMove(moveDist: Vector2) -> void:
  for block: EditorBlock in attach_parents:
    block.attach_children.erase(self)
  attach_parents = []
  if self in global.boxSelect_selectedBlocks and moveDist != Vector2.ZERO:
    isBeingMoved = true
    log.pp("isBeingMoved")
    for block in global.boxSelect_selectedBlocks:
      if block == self: continue
      block.startPosition += moveDist
      block.global_position += moveDist
      block.onEditorMove(Vector2.ZERO)
  queue_redraw()
  respawn()

var firstRespawn := true
## don't overite - use on_respawn instead
func respawn() -> void:
  if not global.currentLevelSettings("checkpointsSaveAll"):
    loadDefaultData = true
  if REMOVE_ON_RESPAWN and not firstRespawn:
    queue_free()
  firstRespawn = false
  respawning = 2
  if thingThatMoves:
    thingThatMoves.position = Vector2.ZERO
    intendedPositionOfThingThatMoves = thingThatMoves.global_position

  for block: EditorBlock in attach_children:
    if !block.thingThatMoves:
      log.err("no thingThatMoves", block.id)
      breakpoint
    # log.pp(block == self, block.name, block.id, self.name, self.id)
    block.respawn()
  attach_children = []
  if not DONT_MOVE_ON_RESPAWN:
    global_position = startPosition
    rotation_degrees = startRotation_degrees
    scale = startScale
  if !isBeingMoved and not DONT_ENABLE_ON_RESPAWN:
    __enable.call_deferred()

  for sprite in hidableSprites:
    sprite.modulate = Color(selectedOptions.color)
  if not REMOVE_ON_RESPAWN:
    for thing in cloneEventsHere:
      if 'on_respawn' in thing:
        thing.on_respawn()
    on_respawn()

var onBottomSide := false
var onTopSide := false
var onLeftSide := false
var onRightSide := false

var last_input_event: InputEvent
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
  if global.ui.modifiers.editorOpen: return
  for thing in cloneEventsHere:
    if 'on_input_event' in thing:
      thing.on_input_event(viewport, event, shape_idx)
  if last_input_event == event: return
  last_input_event = event

  if not EDITOR_IGNORE:
    if isHovered and self not in global.hoveredBlocks:
      global.hoveredBlocks.append(self)
  # if event is InputEventMouseMotion and !event.is_echo() and (event as InputEventMouseMotion).relative:
  #   # log.pp(event.relative)
  #   if not EDITOR_IGNORE:
  #     if isHovered and self not in global.hoveredBlocks:
  #       global.hoveredBlocks.append(self)
  # if selecting this block
  if not global.shouldDragBlock and global.hoveredBlocks && self == global.hoveredBlocks[0]:
    if !Input.is_action_pressed(&"editor_pan"):
      # edit block menu on rbutton
      # if event.is_action_pressed(&"editor_edit_special") \
      #   && Input.is_action_just_pressed(&"editor_edit_special") \
      #   and not global.openMsgBoxCount \
      #   and not global.hoveredBrushes \
      #   :
      #   # log.pp(event.to_string(), shape_idx, viewport)
      #   if NO_RCLICK_MENU: return
      #   if not pm: return
      #   # log.pp(blockOptions, event.as_text(), self, self.name)
      #   showPopupMenu()
      # select blocks when clicking them
      if event.is_action_pressed(&"editor_select") && Input.is_action_just_pressed(&"editor_select"):
        # if NO_SELECTING:
        #   global.hoveredBlocks.pop_front()
        #   if not global.hoveredBlocks: return
        respawn()
        global.selectBlock.call_deferred()

var collisionQueue := {}
## don't overite - use on_body_entered instead
func _on_body_entered(body: Node2D, real=true) -> void:
  if !global.player: return
  if global.player.state == Player.States.levelLoading: return
  if global.player.state == Player.States.dead and not SEND_COLLISIONS_DOURING_PLAYER_RESPAWN: return
  on_body_entered(body)
  if is_in_group("death"):
    _on_body_enteredDEATH(body)

## don't overite - use on_body_exited instead
func _on_body_exited(body: Node2D, real=true) -> void:
  if !global.player: return
  if global.player.state == Player.States.levelLoading: return
  if global.player.state == Player.States.dead and not SEND_COLLISIONS_DOURING_PLAYER_RESPAWN: return
  # if global.player.state == Player.States.dead and body is Player: return
  if respawning:
    if body in collisionQueue and collisionQueue[body] == "entered":
      collisionQueue.erase(body)
    else:
      collisionQueue[body] = "exited"
    return
  on_body_exited(body)
  if is_in_group("death"):
    _on_body_exitedDEATH(body)

func clearSaveData():
  loadDefaultData = true
  respawn()
  for thing in cloneEventsHere:
    if 'on_ready' in thing:
      thing.on_ready()
  on_ready()
  updateConnectedBlocks(false)
  queue_redraw()

## don't overite - use on_ready instead
func _ready() -> void:
  global.signalSenderChanged.connect(func(id, on, callers):
    if canHaveSignalLines and self in callers:
      if global.player.respawnCooldown > 0: return
      updateConnectedBlocks(false)
      queue_redraw())
  global.onEditorStateChanged.connect(queue_redraw)

  if KILL_AFTER_TIME:
    get_tree().create_timer(KILL_AFTER_TIME).timeout.connect(queue_free)
  # hasBeenExploded = false
  if !global.player:
    generateBlockOpts()
    if canAttachToThings:
      blockOptions.canAttachToThings = {"type": global.PromptTypes.bool, "default": true}
    if canAttachToPaths:
      blockOptions.canAttachToPaths = {"type": global.PromptTypes.bool, "default": true}
    if not NO_CUSTOM_COLOR_IN_MENU:
      blockOptions.color = {"type": global.PromptTypes.rgba, "default": "#fff"}
    return

  # if REMOVE_ON_PLAYER_DEATH:
  #   if global.player.OnPlayerDied.is_connected(queue_free):
  #     queue_free()
  #     return
  #   global.player.OnPlayerDied.connect(queue_free)
  if !global.player.OnPlayerFullRestart.is_connected(clearSaveData):
    global.player.OnPlayerFullRestart.connect(clearSaveData)
  if !global.player.OnPlayerDied.is_connected(respawn):
    global.player.OnPlayerDied.connect(respawn)
  blockOptions = {}

  if not hidableSprites and not ignoreMissingNodes:
    log.err("hidableSprites is null", self, name, id)
    breakpoint
  if null in hidableSprites:
    log.err("a hidableSprites is null", self, name, id)
    breakpoint

  # if not ('color' in selectedOptions):
  #   selectedOptions.color='#fff'
  # for thing in hidableSprites:
  #   var shader = preload("res://scenes/blocks/oneway/main.tres").duplicate()
  #   shader.set_shader_parameter("start", mainColor)
  #   shader.set_shader_parameter("end", Color(selectedOptions.color))
  #   thing.use_parent_material = false
  #   thing.material = shader

  if not collisionShapes:
    if get_node_or_null("CollisionShape2D"):
      collisionShapes = [$CollisionShape2D]
    elif not ignoreMissingNodes:
      log.err("collisionShapes is null", self, name, id)
      breakpoint
  if null in collisionShapes:
    log.err("a collisionShapes is null", self, name, id)
    breakpoint

  if not EDITOR_IGNORE and not ghost:
    createEditorGhost()
  generateBlockOpts()
  if canAttachToThings:
    blockOptions.canAttachToThings = {"type": global.PromptTypes.bool, "default": true}
  if canAttachToPaths:
    blockOptions.canAttachToPaths = {"type": global.PromptTypes.bool, "default": true}

  if not NO_CUSTOM_COLOR_IN_MENU:
    blockOptions.color = {"type": global.PromptTypes.rgba, "default": "#fff"}
  for k in blockOptions:
    if global.same(blockOptions[k].type, global.PromptTypes._enum):
      if !(blockOptions[k].values is Array):
        blockOptions[k].values = blockOptions[k].values.keys()
  setupOptions()
  self.visibility_layer = 2
  var node_stack: Array[Node] = [ self ]
  while not node_stack.is_empty():
    var node: Node = node_stack.pop_back()
    if is_instance_valid(node) and 'visibility_layer' in node:
      node.visibility_layer = 2
      node_stack.append_array(node.get_children())
  __enable.call_deferred()
  respawn.call_deferred()
  for thing in cloneEventsHere:
    if 'on_ready' in thing:
      thing.on_ready()
  on_ready()
  if not is_inside_tree():
    log.err(self, name, id, "not inside tree!!")
    queue_free()

func toType(opt: Variant) -> void:
  match blockOptions[opt].type:
    global.PromptTypes.string:
      selectedOptions[opt] = str(selectedOptions[opt])
    global.PromptTypes.int:
      selectedOptions[opt] = int(selectedOptions[opt])
    global.PromptTypes.float:
      selectedOptions[opt] = float(selectedOptions[opt])
    global.PromptTypes.bool:
      selectedOptions[opt] = bool(selectedOptions[opt])
    global.PromptTypes.confirm:
      selectedOptions[opt] = bool(selectedOptions[opt])
    global.PromptTypes._enum:
      selectedOptions[opt] = selectedOptions[opt]
    _:
      selectedOptions[opt] = selectedOptions[opt]

func setupOptions() -> void:
  if !blockOptions:
    log.err(id, name, "no blockOptions!!!")
    return
  for opt: String in blockOptions:
    if opt in selectedOptions:
      toType(opt)
    else:
      if id in global.defaultBlockOpts \
      and opt in global.defaultBlockOpts[id] \
      :
        selectedOptions[opt] = global.defaultBlockOpts[id][opt]
      elif "default" in blockOptions[opt]:
        selectedOptions[opt] = blockOptions[opt].default
        toType(opt)
      else:
        if !global.same(blockOptions[opt].type, 'BUTTON'):
          log.err("no default value set for " + opt + ' in block ' + id)
          breakpoint
  # blockOptionsArray = []
  # for k: String in blockOptions:
  #   blockOptionsArray.append(k)

## don't overite - use on_physics_process instead or postMovementStep to get called after the node has moved
func _physics_process(delta: float) -> void:
  if !global.player: return
  if isBeingPlaced:
    if !(global.selectedBlock == self):
      isBeingPlaced = false
  # if global.player.state == Player.States.dead: return
  # if global.stopTicking: return
  if global.ui.modifiers.editorOpen: return
  if global.openMsgBoxCount: return
  if (global.selectedBlock == self || self in global.boxSelect_selectedBlocks) && Input.is_action_pressed(&"editor_select"): return
  if _DISABLED and not dontDisablePhysicsProcess: return
  var lastpos: Vector2 = thingThatMoves.global_position if thingThatMoves else Vector2.ZERO
  for thing in cloneEventsHere:
    if 'on_physics_process' in thing:
      thing.on_physics_process(0 if global.stopTicking else delta)
  on_physics_process(0 if global.stopTicking else delta)
  lastMovementStep = (
    thingThatMoves.global_position
    if thingThatMoves else
    global_position
  ) - lastpos
  if respawning:
    respawning -= 1
    if not respawning:
      __enable()
      updateConnectedBlocks(false)
      queue_redraw()

  if global.stopTicking: return
  for thing in cloneEventsHere:
    if not thing:
      log.err(id, "no thing in cloneEventsHere")
      breakpoint
    if 'postMovementStep' in thing:
      thing.postMovementStep()
  postMovementStep()
  if thingThatMoves:
    for block: EditorBlock in attach_children:
      if !block.thingThatMoves:
        log.err("no thingThatMoves", block.id)
        breakpoint
      block.thingThatMoves.position += lastMovementStep.rotated(-block.rotation) / block.global_scale
func postMovementStep(): pass
var left_edge: float
var right_edge: float
var top_edge: float
var bottom_edge: float
var canHaveSignalLines := 0
var connectedBlocks := []
func updateConnectedBlocks(full: bool) -> void:
  if canHaveSignalLines == -1: return
  if respawning: return
  var checksForOtherBlocks = []
  var checksForThisBlock = []
  var canHaveSignalLinesChecks = 2
  var inputs := ["signalAInputId", "signalBInputId", "signalInputId", "enableSignalInputId", "disableSignalInputId"]
  var outputs := ["signalOutputId"]
  # if !full:
  #   breakpoint
  if global.level.allBlocks != global.arr.unique(global.level.allBlocks):
    breakpoint
  if connectedBlocks != global.arr.unique(connectedBlocks):
    breakpoint
  var blocksToCheck = global.arr.unique(global.level.allBlocks if full else connectedBlocks.duplicate().map(func(e): return e[0]))
  # log.err("connected blocks: ", blocksToCheck)
  connectedBlocks = []
  for thing in inputs:
    if thing in selectedOptions and selectedOptions[thing]:
      checksForOtherBlocks += outputs
      checksForThisBlock.append(thing)
  if checksForThisBlock:
    connectedBlocks += (blocksToCheck) \
    .map(
      func(e):
        var found=0
        for thing in checksForOtherBlocks:
          if !global.isAlive(e): return [e, found]
          if thing in e.selectedOptions \
          and e.selectedOptions[thing] in checksForThisBlock.map(func(e): return selectedOptions[e]):
            if found < 1:
              found=1
            if e.selectedOptions[thing] in global.activeSignals \
            and global.activeSignals[e.selectedOptions[thing]]:
              if self in global.activeSignals[e.selectedOptions[thing]] \
              if thing in inputs else \
              e in global.activeSignals[e.selectedOptions[thing]] \
              :
                found=2
              break
        return [e, found]
    ).filter(func(e): return e[1])
  else:
    canHaveSignalLinesChecks -= 1
  checksForOtherBlocks = []
  checksForThisBlock = []
  for thing in outputs:
    if thing in selectedOptions and selectedOptions[thing]:
      checksForOtherBlocks += inputs
      checksForThisBlock.append(thing)
  if checksForThisBlock:
    connectedBlocks += (blocksToCheck) \
    .map(
      func(e):
        var found=0
        for thing in checksForOtherBlocks:
          if !global.isAlive(e): return [e, found]
          if thing in e.selectedOptions \
          and e.selectedOptions[thing] in checksForThisBlock.map(func(e): return selectedOptions[e]):
            if found < 1:
              found=1
            if e.selectedOptions[thing] in global.activeSignals \
            and global.activeSignals[e.selectedOptions[thing]]:
              if self in global.activeSignals[e.selectedOptions[thing]] \
              if thing in inputs else \
              e in global.activeSignals[e.selectedOptions[thing]] \
              :
                found=2
              break
        return [e, found]
    ).filter(func(e): return e[1] and e not in connectedBlocks)
  else:
    canHaveSignalLinesChecks -= 1
  if canHaveSignalLinesChecks:
    canHaveSignalLines = 1
  else:
    canHaveSignalLines = -1
    global.level.allBlocks.erase(self)
  # var temp = connectedBlocks.duplicate().map(func(e): return e[0])
  # connectedBlocks = connectedBlocks.filter(func(e): not (e in temp))
  # log.pp(connectedBlocks
  # log.pp(checksForThisBlock, checksForOtherBlocks)
  # if not checksForThisBlock:
  #   connectedBlocks = []

func getLinesTo(block: EditorBlock) -> Array:
  var lines: Array = []
  var start_point = position
  var end_point = block.position

  # Calculate differences
  var dx = end_point.x - start_point.x
  var dy = end_point.y - start_point.y

  if dx == 0 and dy == 0:
    return lines

  var intermediate_point = Vector2()

  if dx > 0: # When moving right
    intermediate_point.x = end_point.x
    intermediate_point.y = start_point.y
    if abs(dx) > abs(dy):
      intermediate_point.x -= (sign(dx) * abs(dy))
    else:
      intermediate_point.y += (sign(dy) * abs(dx))

    lines.append([intermediate_point, end_point])
    lines.append([start_point, intermediate_point])
  else:
    intermediate_point = Vector2(start_point.x, end_point.y)
    if abs(dx) > abs(dy):
      intermediate_point.x += (sign(dx) * abs(dy))
    else:
      intermediate_point.y -= (sign(dy) * abs(dx))
    lines.append([start_point, intermediate_point])
    lines.append([intermediate_point, end_point])

  return lines

func _draw():
  if canHaveSignalLines == 1 and (
    (lineDrawEnabled and global.useropts.showSignalConnectionLinesOnHover) \
    or global.useropts.showSignalConnectionLinesInEditor and global.showEditorUi \
    or global.useropts.showSignalConnectionLinesInPlay and !global.showEditorUi \
  ):
    if global.useropts.onlyShowSignalConnectionsIfHoveringOverAny:
      if global.selectedBlock:
        if global.selectedBlock != self:
          if global.selectedBlock.connectedBlocks: return
      else:
        if global.hoveredBlocks and global.hoveredBlocks[0] != self:
          if global.hoveredBlocks[0].connectedBlocks: return

    for thing: Array in connectedBlocks:
      var block: EditorBlock = thing[0]
      var signalActive = thing[1]
      for line in getLinesTo(block):
        draw_line(to_local(line[0]), to_local(line[1]), [Color("#a00"), Color("#0a0")][signalActive - 1], -1)

var lineDrawEnabled := false

## don't overite - use on_process instead
func _process(delta: float) -> void:
  # queue_redraw.call_deferred()
  if !global.player: return
  # if EDITOR_IGNORE: return
  # if not ghost: return
  if global.ui.modifiers.editorOpen: return
  if global.openMsgBoxCount: return
  if !_DISABLED:
    for node in hidableSprites:
      if global.showEditorUi:
        node.visible = !global.hideNonGhosts
      else:
        node.visible = true

  if not EDITOR_IGNORE:
    if self in global.hoveredBlocks and !isHovered:
      global.hoveredBlocks.erase(self)
  if BUZZSAW_GENERIC_spriteToRotateLeft and BUZZSAW_GENERIC_spriteToRotateRight:
    _processBUZZSAW_GENERIC(delta)
  if not EDITOR_IGNORE:
    ghost.use_parent_material = true
    if global.hoveredBlocks && self == global.hoveredBlocks[0] \
      or self in global.boxSelect_selectedBlocks: # and not NO_SELECTING:
      ghost.modulate.a = 1
    else:
      ghost.modulate.a = global.useropts.blockGhostAlpha
    ghost.visible = global.showEditorUi
  var lastLineDraw := lineDrawEnabled
  if global.showEditorUi:
    if global.selectedBlock:
      if global.selectedBlock == self:
        lineDrawEnabled = true
      else:
        lineDrawEnabled = false
    else:
      if global.hoveredBlocks and global.hoveredBlocks[0] == self:
        lineDrawEnabled = true
      else:
        lineDrawEnabled = false
  if lineDrawEnabled != lastLineDraw:
    queue_redraw()

  if Input.is_action_pressed(&"editor_box_select"): return
  if not EDITOR_IGNORE \
  and global.showEditorUi and (
    not Input.is_action_pressed(&"editor_pan")
    or self in global.boxSelect_selectedBlocks
  ):
    if global.selectedBlock == self:
      if Input.is_action_pressed(&"editor_select"):
        if self not in global.boxSelect_selectedBlocks:
          global.boxSelect_selectedBlocks = []
        global_position = startPosition
        if not _DISABLED:
          isBeingMoved = true
          queue_redraw()
          for collider in collisionShapes:
            if not collider:
              log.pp(collider, collisionShapes, id)
              breakpoint
            collider.disabled = true
      if global.level.grabbingImage:
        ghost.use_parent_material = true
      else:
        ghost.use_parent_material = false
      ghost.material.set_shader_parameter("color", Color.hex(global.useropts.selectedBlockOutlineColor))
    else:
      # if not mouse down
      if !Input.is_action_pressed(&"editor_select"):
        if not _DISABLED:
          if isBeingMoved:
            onEditorMoveEnded()
            for thing in cloneEventsHere:
              if 'on_ready' in thing:
                thing.on_ready()
            on_ready()
            isBeingMoved = false
          for collider in collisionShapes:
            if not collider and not ignoreMissingNodes:
              log.pp("invalid collisionShapes", collider, collisionShapes, id)
              breakpoint
            collider.disabled = false
        # set border to hovered color
      ghost.material.set_shader_parameter("color", Color.hex(global.useropts.hoveredBlockOutlineColor))
      # and if first hovered block, show border
      if global.hoveredBlocks && self == global.hoveredBlocks[0] \
        or self in global.boxSelect_selectedBlocks: # and not NO_SELECTING:
        if !Input.is_action_pressed(&"editor_select"):
          # prevents the mouse position from being offset by the players offset from the last frame
          global.player.updateCamLockPos()
          var mouse_pos := get_global_mouse_position().rotated(-deg_to_rad(startRotation_degrees))

          var node_pos := ghost.global_position.rotated(-deg_to_rad(startRotation_degrees))
          var node_size: Vector2 = ghost.texture.get_size() * ghost.scale * scale
          left_edge = node_pos.x - node_size.x / 2
          right_edge = node_pos.x + node_size.x / 2
          top_edge = node_pos.y - node_size.y / 2
          bottom_edge = node_pos.y + node_size.y / 2

          var leftDist: float = abs(mouse_pos.x - left_edge)
          var rightDist: float = abs(mouse_pos.x - right_edge)
          var topDist: float = abs(mouse_pos.y - top_edge)
          var bottomDist: float = abs(mouse_pos.y - bottom_edge)
          var testDist := 7

          # set the sides that you are close enough to to be selecting
          onTopSide = topDist < testDist
          onBottomSide = bottomDist < testDist
          if onTopSide and onBottomSide:
            if topDist < bottomDist:
              onBottomSide = false
            else:
              onTopSide = false

          onLeftSide = leftDist < testDist
          onRightSide = rightDist < testDist
          if onLeftSide and onRightSide:
            if leftDist < rightDist:
              onRightSide = false
            else:
              onLeftSide = false
          if global.useropts.noCornerGrabsForScaling:
            if onTopSide and onRightSide:
              if node_size.y < node_size.x:
                onTopSide = false
              else:
                onRightSide = false
            elif onTopSide and onLeftSide:
              if node_size.y < node_size.x:
                onTopSide = false
              else:
                onLeftSide = false
            elif onBottomSide and onRightSide:
              if node_size.y < node_size.x:
                onBottomSide = false
              else:
                onRightSide = false
            elif onBottomSide and onLeftSide:
              if node_size.y < node_size.x:
                onBottomSide = false
              else:
                onLeftSide = false

          # var v = boolsToV2(onTopSide, onBottomSide, onLeftSide, onRightSide).rotated(deg_to_rad(startRotation_degrees))
          # store the selected sides in global
          global.scaleOnTopSide = onTopSide
          global.scaleOnBottomSide = onBottomSide
          global.scaleOnRightSide = onRightSide
          global.scaleOnLeftSide = onLeftSide
          # global.scaleOnTopSide = v.y == -1
          # global.scaleOnBottomSide = v.y == 1
          # global.scaleOnRightSide = v.x == 1
          # global.scaleOnLeftSide = v.x == -1
          # log.pp("ed", onLeftSide, onRightSide)

        ghost.material.set_shader_parameter("xSize", global.useropts.blockOutlineSize / (sizeInPx.x / 100))
        ghost.material.set_shader_parameter("ySize", global.useropts.blockOutlineSize / (sizeInPx.y / 100))
        # show what sides are being selected if editorInScaleMode and is scalable or all if selected with box select
        ghost.material.set_shader_parameter("showTop",
          self in global.boxSelect_selectedBlocks or \
          not global.editorInScaleMode or \
          (
            onTopSide and
            global.editorInScaleMode and
            (
              EDITOR_OPTION_scale or
              global.useropts.allowScalingAnything
            )
          )
        )
        ghost.material.set_shader_parameter("showBottom",
          self in global.boxSelect_selectedBlocks or \
          not global.editorInScaleMode or \
          (
            onBottomSide and
            global.editorInScaleMode and
            (
              EDITOR_OPTION_scale or
              global.useropts.allowScalingAnything
            )
          )
        )
        ghost.material.set_shader_parameter("showLeft",
          self in global.boxSelect_selectedBlocks or \
          not global.editorInScaleMode or \
          (
            onLeftSide and
            global.editorInScaleMode and
            (
              EDITOR_OPTION_scale or
              global.useropts.allowScalingAnything
            )
          )
        )
        ghost.material.set_shader_parameter("showRight",
          self in global.boxSelect_selectedBlocks or \
          not global.editorInScaleMode or \
          (
            onRightSide and
            global.editorInScaleMode and
            (
              EDITOR_OPTION_scale or
              global.useropts.allowScalingAnything
            )
          )
        )
        if global.level.grabbingImage:
          ghost.use_parent_material = true
        else:
          ghost.use_parent_material = false
      else:
        # disable outline
        ghost.use_parent_material = true
  if global.player.state == Player.States.dead: return
  on_process(delta)

func createEditorGhost() -> void:
  if not ghostIconNode:
    log.err("ghost icon node is null", name)
    breakpoint
  ghost = ghostIconNode.duplicate()
  # ghostIconNode.texture = load(
  #   ghostIconNode.texture.resource_path \
  #   .replace("/editorBar1.png", '/editorBar' + str(global.currentLevelSettings("color")) + '.png') \
  #   .replace("/1.png", '/' + str(global.currentLevelSettings("color")) + '.png')
  # )
  # log.err(global.currentLevelSettings("color"), ghostIconNode.texture.resource_path, ghostIconNode.texture)
  ghost.material = preload("res://scenes/blocks/selectedBorder.tres").duplicate()
  ghost.scale = ghostIconNode.scale
  ghost.name = "ghost"
  # ghost.modulate.a = .2
  var collider := Area2D.new()
  collider.set_script(preload("res://scenes/blocks/root.gd"))
  collider.root = self
  collider.collision_layer = 524288
  collider.collision_mask = 524288
  collider.connect("mouse_entered", _on_mouse_entered)
  collider.connect("mouse_exited", _on_mouse_exited)
  collider.connect("input_event", _on_input_event)
  collider.name = "collider"
  collider.input_pickable = true
  var collisionShape := CollisionShape2D.new()
  var rectangle := RectangleShape2D.new()
  if not ghost.get_texture():
    log.err("no ghost texture", id, name, ghostIconNode.get_texture(), ghost, ghost.get_texture())
    breakpoint
  rectangle.size = ghost.get_texture().get_size()
  defaultSizeInPx = ghost.get_texture().get_size() * ghost.scale
  # collisionShape.debug_color = Color("#5d40643f")
  collisionShape.debug_color = Color("#00000010")
  collisionShape.set_shape(rectangle)
  collider.add_child(collisionShape)
  ghost.add_child(collider)
  ghostFollowNode.add_child(ghost)

## spins the node at speed using global tick
func spin(speed: float, node: Node2D = self) -> void:
  node.rotation_degrees = fmod(global.tick * speed, 360.0)

## returns the name of the texture of a node
func getTexture(node: Node2D) -> String:
  return global.regMatch(node.texture.resource_path, r'/([^/]+)\.png$')[1].strip_edges()

## sets the texture of a node to a given name from the same folder as the previous texture
func setTexture(node: Node, newTexture: String) -> void:
  node.texture = load(global.regReplace(node.texture.resource_path, '/[^/]+$', '/' + str(newTexture) + '.png'))

## disables the node collision and hides the sprites
func __disable() -> void:
  # if _DISABLED: return
  _DISABLED = true
  for thing in cloneEventsHere:
    if 'on_disable' in thing:
      thing.on_disable()
  for collider in collisionShapes:
    collider.disabled = true
  for sprite in hidableSprites:
    sprite.visible = false
func __hideAll() -> void:
  _DISABLED = true
  for sprite in hidableSprites:
    sprite.visible = false
  # get_parent().collisionShapes.map(func(e):return e.disabled)
## enables the node collision and shows the sprites
func __enable() -> void:
  # if not _DISABLED: return
  _DISABLED = false
  for thing in cloneEventsHere:
    if 'on_enable' in thing:
      thing.on_enable()
  for collider in collisionShapes:
    collider.disabled = false
  for sprite in hidableSprites:
    sprite.visible = true

# blocks
@export_group("DEATH")
func _on_body_enteredDEATH(body: Node) -> void:
  if body is Player:
    if self not in global.player.deathSources:
      global.player.deathSources.append(self)

func _on_body_exitedDEATH(body: Node) -> void:
  if body is Player:
    if self in global.player.deathSources:
      global.player.deathSources.erase(self)

# res://scenes/blocks/buzzsaw/images/1.png
@export_group("BUZZSAW - GENERIC")
@export var BUZZSAW_GENERIC_spriteToRotateLeft: Sprite2D
@export var BUZZSAW_GENERIC_spriteToRotateRight: Sprite2D
func _processBUZZSAW_GENERIC(delta: float) -> void:
  var speed = 80.0
  spin(-speed, BUZZSAW_GENERIC_spriteToRotateLeft)
  spin(speed, BUZZSAW_GENERIC_spriteToRotateRight)
