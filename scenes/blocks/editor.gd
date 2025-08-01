@icon("res://images/sprites/DefineSprite_1608/1.png")
class_name EditorBlock
extends Node2D
## sprite to use for the ghost
@export var ghostIconNode: Sprite2D
## sprite to show in the editor bar
@export var editorBarIconNode: Sprite2D
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
## prevents selecting this block - selection box still appears, need to fix later
@export var NO_SELECTING: bool = false

## prevents selecting this block - selection box still appears, need to fix later

@export var EDITOR_OPTION_scale: bool = false
@export var EDITOR_OPTION_rotate: bool = false
@export var canAttachToThings: bool = false
@export var canAttachToPaths: bool = false

var isBeingPlaced := false

enum boolOrNull {
  _false = -1,
  _true = 1,
  _null = 0,
  no = -1,
  yes = 1,
  unset = 0,
}

var onOptionEdit := func() -> void: pass

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
var blockOptionsArray := []
## used for following blocks
var attach_children: Array[EditorBlock] = []:
  get():
    attach_children = attach_children.filter(global.isAlive)
    return attach_children
## used for following blocks
var attach_parents: Array[EditorBlock] = []:
  get():
    attach_parents = attach_parents.filter(global.isAlive)
    return attach_parents
## when being moved in the editor
var isBeingMoved := false
## the positional offset caused by setting following to false in attach detector
var unusedOffset = Vector2.ZERO

# var currentPath: PathFollow2D

## overite this to return properties to save
func onSave() -> Array[String]:
  return []

func onEditorRotate(): pass

func _on_mouse_entered() -> void:
  isHovered = true

func _on_mouse_exited() -> void:
  isHovered = false

func onEditorMove(moveDist: Vector2) -> void:
  for block: EditorBlock in attach_parents:
    block.attach_children.erase(self )
  attach_parents = []
  if self in global.boxSelect_selectedBlocks and moveDist != Vector2.ZERO:
    isBeingMoved = true
    log.pp("isBeingMoved")
    for block in global.boxSelect_selectedBlocks:
      if block == self: continue
      block.startPosition += moveDist
      block.global_position += moveDist
      block.onEditorMove(Vector2.ZERO)
  respawn()

## overite this to receive event when data for this block is loaded
func onDataLoaded() -> void:
  pass
## overite this to receive event when data for all blocks loaded
func onAllDataLoaded() -> void:
  pass

## don't overite - use on_respawn instead
func respawn() -> void:
  respawning = 2
  if thingThatMoves:
    thingThatMoves.position = Vector2.ZERO

  for block: EditorBlock in attach_children:
    if !block.thingThatMoves:
      log.err("no thingThatMoves", block.id)
      breakpoint
    # log.pp(block == self , block.name, block.id, self.name, self.id)
    block.respawn()
  attach_children = []
  if not DONT_MOVE_ON_RESPAWN:
    global_position = startPosition
    rotation_degrees = startRotation_degrees
    scale = startScale
  if !isBeingMoved and not DONT_ENABLE_ON_RESPAWN:
    __enable.call_deferred()

  for thing in cloneEventsHere:
    if 'on_respawn' in thing:
      thing.on_respawn()
  on_respawn()

func on_respawn():
  pass

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
  # if selecting this block
  if global.hoveredBlocks && self == global.hoveredBlocks[0]:
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
        if NO_SELECTING:
          global.hoveredBlocks.pop_front()
          if not global.hoveredBlocks: return
        respawn()
        global.selectBlock()

var collisionQueue := {}
## don't overite - use on_body_entered instead
func _on_body_entered(body: Node2D, real=true) -> void:
  if global.player.state == global.player.States.levelLoading: return
  if global.player.state == global.player.States.dead and not SEND_COLLISIONS_DOURING_PLAYER_RESPAWN: return
  on_body_entered(body)
  if is_in_group("death"):
    _on_body_enteredDEATH(body)

func on_body_entered(body: Node2D): pass
func on_body_exited(body: Node2D): pass

## don't overite - use on_body_exited instead
func _on_body_exited(body: Node2D, real=true) -> void:
  if global.player.state == global.player.States.levelLoading: return
  if global.player.state == global.player.States.dead and not SEND_COLLISIONS_DOURING_PLAYER_RESPAWN: return
  # if global.player.state == global.player.States.dead and body is Player: return
  if respawning:
    if body in collisionQueue and collisionQueue[body] == "entered":
      collisionQueue.erase(body)
    else:
      collisionQueue[body] = "exited"
    return
  on_body_exited(body)
  if is_in_group("death"):
    _on_body_exitedDEATH(body)

## don't overite - use on_ready instead
func _ready() -> void:
  if !global.player.OnPlayerFullRestart.is_connected(_ready):
    global.player.OnPlayerFullRestart.connect(_ready)
  # if !is_in_group("dontRespawnOnPlayerDeath"):
  if !global.player.OnPlayerDied.is_connected(respawn):
    global.player.OnPlayerDied.connect(respawn)

  blockOptions = {}

  if not hidableSprites and not ignoreMissingNodes:
    log.err("hidableSprites is null", self , name, id)
    breakpoint
  if null in hidableSprites:
    log.err("a hidableSprites is null", self , name, id)
    breakpoint

  if not collisionShapes:
    if get_node_or_null("CollisionShape2D"):
      collisionShapes = [$CollisionShape2D]
    elif not ignoreMissingNodes:
      log.err("collisionShapes is null", self , name, id)
      breakpoint
  if null in collisionShapes:
    log.err("a collisionShapes is null", self , name, id)
    breakpoint

  if not EDITOR_IGNORE and not ghost:
    createEditorGhost()
  generateBlockOpts()

  if canAttachToThings:
    blockOptions.canAttachToThings = {"type": global.PromptTypes.bool, "default": true}
  if canAttachToPaths:
    blockOptions.canAttachToPaths = {"type": global.PromptTypes.bool, "default": true}

  if global.useropts.allowCustomColors and not NO_CUSTOM_COLOR_IN_MENU:
    blockOptions.color = {"type": global.PromptTypes.rgba, "default": "#fff"}
  setupOptions()

  __enable.call_deferred()
  respawn.call_deferred()
  if global.useropts.allowCustomColors and not NO_CUSTOM_COLOR_IN_MENU:
    self.modulate = Color(selectedOptions.color)
  for thing in cloneEventsHere:
    if 'on_ready' in thing:
      thing.on_ready()
  on_ready()
func on_ready(): pass

func generateBlockOpts():
  pass

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
  # if pm: return
  if selectedOptions: return
  if !blockOptions: return
  for opt: String in blockOptions:
    if opt in selectedOptions:
      toType(opt)
      continue
    if id in global.defaultBlockOpts \
    and opt in global.defaultBlockOpts[id] \
    :
      # log.pp("Default for option: ", opt, " is ", global.defaultBlockOpts[id][opt], "\n")
      selectedOptions[opt] = global.defaultBlockOpts[id][opt]
    elif "default" in blockOptions[opt]:
      selectedOptions[opt] = blockOptions[opt].default
      toType(opt)
  # var can := CanvasLayer.new()
  # add_child(can)
  # # pm = PopupMenu.new()
  # can.add_child(pm)
  # pm.system_menu_id = NativeMenu.SystemMenus.DOCK_MENU_ID
  # var i := 0
  blockOptionsArray = []
  for k: String in blockOptions:
    blockOptionsArray.append(k)
  #   pm.add_item('', i)
  #   i += 1
  # pm.add_item('cancel', i)
  # pm.connect("index_pressed", editOption)

func editOption(idx: int) -> void:
  if idx >= len(blockOptionsArray):
    onOptionEdit.call()
    return
  # log.pp("editing", idx, blockOptions)
  var k: String = blockOptionsArray[idx]
  var newData: Variant
  if blockOptions[k].type is global.PromptTypes:
    newData = await global.prompt(
      k,
      blockOptions[k].type,
      selectedOptions[k],
      blockOptions[k].default,
      blockOptions[k].values if "values" in blockOptions[k] else []
    )
  elif blockOptions[k].type == 'BUTTON':
    if blockOptions[k].onChange.call():
      respawn()
      _ready()
    onOptionEdit.call()
    return
  else:
    log.err("unknown type", k, blockOptions[k])
    breakpoint
  if \
  'onChange' not in blockOptions[k] \
  or blockOptions[k].onChange.call(selectedOptions[k]):
    selectedOptions[k] = newData
    toType(k)
  # log.pp(newData, "newData")
  # if !newData: return
  respawn()
  _ready()
  onOptionEdit.call()

func on_physics_process(delta: float) -> void: pass

## don't overite - use on_physics_process instead or postMovementStep to get called after the node has moved
func _physics_process(delta: float) -> void:
  if isBeingPlaced:
    if !(global.selectedBlock == self ):
      isBeingPlaced = false
  if global.player.state == global.player.States.dead: return
  if global.stopTicking: return
  if global.ui.modifiers.editorOpen: return
  if global.openMsgBoxCount: return
  if (global.selectedBlock == self || self in global.boxSelect_selectedBlocks) && Input.is_action_pressed(&"editor_select"): return
  if _DISABLED and not dontDisablePhysicsProcess: return
  var lastpos: Vector2 = thingThatMoves.global_position if thingThatMoves else global_position
  #
  # if currentPath:
    # if not pathFollowNode:
    #   log.err("no path follow node", id)
    #   breakpoint
    # pathFollowNode.position += currentPath.lastMovementStep * currentPath.scale
  #
  for thing in cloneEventsHere:
    if 'on_physics_process' in thing:
      thing.on_physics_process(delta)
  on_physics_process(delta)
  # if respawning:
  #   lastMovementStep = Vector2.ZERO
  # else:
  lastMovementStep = (
    thingThatMoves.global_position
    if thingThatMoves else
    global_position
  ) - lastpos
  if respawning:
    respawning -= 1

    # if not respawning:
    #   if collisionQueue:
    #     log.pp(collisionQueue, id)
    #     for block in collisionQueue:
    #       if collisionQueue[block] == "exited":
    #         _on_body_exited(block)
    #       else:
    #         _on_body_entered(block)
    #     collisionQueue = {}

  for thing in cloneEventsHere:
    if 'postMovementStep' in thing:
      thing.postMovementStep()
  for block: EditorBlock in attach_children:
    if !block.thingThatMoves:
      log.err("no thingThatMoves", block.id)
      breakpoint
    for thing in block.cloneEventsHere:
      if thing is AttachDetector:
        if thing.following:
          block.thingThatMoves.position += lastMovementStep.rotated(-block.rotation) / block.global_scale
        else:
          block.unusedOffset += lastMovementStep.rotated(-block.rotation) / block.global_scale
var left_edge: float
var right_edge: float
var top_edge: float
var bottom_edge: float

func onEditorMoveEnded(): pass

## don't overite - use on_process instead
func _process(delta: float) -> void:
  if global.player.state == global.player.States.dead: return
  if global.ui.modifiers.editorOpen: return
  if global.openMsgBoxCount: return
  if !_DISABLED:
    for node in hidableSprites:
      if global.showEditorUi:
        node.visible = !global.hideNonGhosts
      else:
        node.visible = true

  # if global.player.state == global.player.States.dead:
  #   respawn()
  #   return
  if is_in_group("buzsaw - generic"):
    _processBUZSAW_GENERIC(delta)

  if not EDITOR_IGNORE:
    if isHovered:
      if self not in global.hoveredBlocks:
        global.hoveredBlocks.append(self )
    else:
      if self in global.hoveredBlocks:
        global.hoveredBlocks.erase(self )

    # if ghostFollowNode == self:
    #   ghost.rotation_degrees = 0
    # else:
    #   log.pp(ghost.global_position, ghostFollowNode.global_position, global_position, id)
    #   ghost.global_position = ghostFollowNode.global_position
    #   ghost.global_rotation = ghostFollowNode.global_rotation
    ghost.use_parent_material = true
    if global.hoveredBlocks && self == global.hoveredBlocks[0] \
      or self in global.boxSelect_selectedBlocks and not NO_SELECTING:
      ghost.modulate.a = global.useropts.hoveredBlockGhostAlpha
    else:
      ghost.modulate.a = global.useropts.blockGhostAlpha

    ghost.visible = global.showEditorUi
    if Input.is_action_pressed(&"editor_box_select"): return
    if global.showEditorUi and not Input.is_action_pressed(&"editor_pan"):
      if global.selectedBlock == self:
        if Input.is_action_pressed(&"editor_select"):
          if self not in global.boxSelect_selectedBlocks:
            global.boxSelect_selectedBlocks = []
          global_position = startPosition
        if not _DISABLED:
          isBeingMoved = true
          for collider in collisionShapes:
            if not collider:
              log.pp(collider, collisionShapes, id)
              breakpoint
            collider.disabled = true
        ghost.use_parent_material = false
        ghost.material.set_shader_parameter("color", Color.hex(global.useropts.selectedBlockOutlineColor))
      else:
        # if not mouse down
        if !Input.is_action_pressed(&"editor_select"):
          if not _DISABLED or 1:
            if isBeingMoved:
              onEditorMoveEnded()
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
            or self in global.boxSelect_selectedBlocks and not NO_SELECTING:
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
            onLeftSide = leftDist < testDist
            onRightSide = rightDist < testDist
            if global.useropts.noCornerGrabsForScaling and node_size.y != node_size.x:
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
            ghost.use_parent_material = false
          else:
            # __disable outline
            ghost.use_parent_material = true
  on_process(delta)

func on_process(delta: float): pass
func onDelete(): pass

func createEditorGhost() -> void:
  if not ghostIconNode:
    log.err("ghost icon node is null", name)
    breakpoint
  ghost = ghostIconNode.duplicate()
  ghost.material = preload("res://scenes/blocks/selectedBorder.tres").duplicate()
  ghost.scale = ghostIconNode.scale
  ghost.name = "ghost"
  # ghost.modulate.a = .2
  var collider := Area2D.new()
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
func spin(speed: float, node: Node2D = self ) -> void:
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
      global.player.deathSources.append(self )

func _on_body_exitedDEATH(body: Node) -> void:
  if body is Player:
    if self in global.player.deathSources:
      global.player.deathSources.erase(self )

# res://scenes/blocks/buzsaw/images/1.png
@export_group("BUZSAW - GENERIC")
@export var BUZSAW_GENERIC_spriteToRotateRight: Sprite2D
@export var BUZSAW_GENERIC_spriteToRotateLeft: Sprite2D
func _processBUZSAW_GENERIC(delta: float) -> void:
  var speed = 80.0
  spin(speed, BUZSAW_GENERIC_spriteToRotateRight)
  spin(-speed, BUZSAW_GENERIC_spriteToRotateLeft)
