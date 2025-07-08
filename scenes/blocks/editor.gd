@icon("res://images/sprites/DefineSprite_1608/1.png")
class_name EditorBlock
extends Node2D
# @name same line return
# @regex :\s*(return|continue|break)\s*$
# @replace : $1
# @flags gm
# @endregex
# @name fix on body entered/exited scripts
# @regex (_on_body_(?:entered|exited).*\()\):?
# @replace $1body: Node):
# @flags gm
# @endregex
# @name fix on body _physics?_process scripts
# @regex \b((?:_physics)?_process.+\()\):?
# @replace $1delta: float):
# @flags gm
# @endregex
# @noregex
# @name auto add export_group
# @regex ^# ([\w ]{2,20})\n(?!@export_group)
# @replace $&@export_group("$1")
#
# @flags gm
# @endregex

## sprite to use for the ghost
@export var ghostIconNode: Sprite2D
## sprite to show in the editor bar
@export var editorBarIconNode: Sprite2D
## sprites to disable when node disabled
@export var collisionShapes: Array[CollisionShape2D]
## sprites to hide when node disabled
@export var hidableSprites: Array[Node]
## sends some events to this node
@export var cloneEventsHere: Node
## the node that lastMovementStep should be calculated from
@export var thingThatMoves: Node
@export var ghostFollowNode: Node = self
@export var mouseRotationOffset = 90
@export_group("misc")
## no warnings when missing unrequired nodes
@export var ignoreMissingNodes := false
## if false scale is 1/7
@export var normalScale := false
## if true don't disable physics process when node is disabled
@export var dontDisablePhysicsProcess := false
## disables editor features suchas moving, scaling, selecting
@export var EDITOR_IGNORE: bool = false
## prevents the node from being moved by respawning
@export var DONT_MOVE: bool = false
@export_group("IGNORE")
@export var pathFollowNode: Node

var onOptionEdit := func() -> void: pass
var sizeInPx: Vector2:
  get():
    return sizeInPx * startScale
  set(value):
    sizeInPx = value
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
## rclick menu
var pm: PopupMenu
## used for following blocks
var attach_children: Array[EditorBlock] = []
## used for following blocks
var attach_parents: Array[EditorBlock] = []
## when being moved in the editor
var isBeingMoved := false
## the positional offset caused by setting following to false in attach detector
var unusedOffset = Vector2.ZERO

# var currentPath: PathFollow2D

## overite this to return properties to save
func onSave() -> Array[String]:
  return []

func _on_mouse_entered() -> void:
  isHovered = true

func _on_mouse_exited() -> void:
  isHovered = false

func onEditorMove(moveDist) -> void:
  for block: EditorBlock in attach_parents.filter(func(e): return is_instance_valid(e)):
    block.attach_children.erase(self )
  attach_parents = []
  if self in global.boxSelect_selectedBlocks:
    for block in global.boxSelect_selectedBlocks:
      if block == self: continue
      block.startPosition += moveDist
      block.global_position += moveDist
      block.respawn()
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
  
  if is_in_group("canBeAttachedTo"):
    for block: EditorBlock in attach_children.filter(func(e): return is_instance_valid(e)):
      if !block.thingThatMoves:
        log.err("no thingThatMoves", block.id)
        breakpoint
      block.respawn()
    attach_children = []
  if not DONT_MOVE:
    global_position = startPosition
    rotation_degrees = startRotation_degrees
    scale = startScale
  if !isBeingMoved:
    __enable.call_deferred()

  if cloneEventsHere and 'on_respawn' in cloneEventsHere:
    cloneEventsHere.on_respawn()
  if 'on_respawn' in self:
    self.on_respawn.call()

var onBottomSide := false
var onTopSide := false
var onLeftSide := false
var onRightSide := false

var last_input_event: InputEvent
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
  if cloneEventsHere and 'on_input_event' in cloneEventsHere:
    cloneEventsHere.on_input_event(viewport, event, shape_idx)
  if last_input_event == event: return
  last_input_event = event
  # if selecting this block
  if global.hoveredBlocks && self == global.hoveredBlocks[0]:
    if !Input.is_action_pressed(&"editor_pan"):
      # edit block menu on rbutton
      if event.is_action_pressed(&"editor_edit_special") \
        && Input.is_action_just_pressed(&"editor_edit_special") \
        and not global.openMsgBoxCount \
        and not global.hoveredBrushes \
        :
        # log.pp(event.to_string(), shape_idx, viewport)
        if not pm: return
        # log.pp(blockOptions, event.as_text(), self, self.name)
        showPopupMenu()
      # select blocks when clicking them
      elif event.is_action_pressed(&"editor_select") && Input.is_action_just_pressed(&"editor_select"):
        respawn()
        global_position = startPosition
        global.selectBlock()

func showPopupMenu():
  if global.popupStarted: return
  var i := 0
  for k: String in blockOptions:
    pm.set_item_text(i, k + ": " + global.PromptTypes.keys()[blockOptions[k].type] + " = " + str(selectedOptions[k]))
    i += 1
  global.popupStarted = true
  pm.popup(Rect2i(get_screen_transform() * get_local_mouse_position(), Vector2i.ZERO))
  await global.wait()
  global.popupStarted = false

var collisionQueue := {}
func _on_body_exited(body: Node2D, real=true) -> void:
  if global.player.state == global.player.States.levelLoading: return
  # if global.player.state == global.player.States.dead and body == global.player: return
  if respawning:
    if body in collisionQueue and collisionQueue[body] == "entered":
      collisionQueue.erase(body)
    else:
      collisionQueue[body] = "exited"
    return
  if 'on_body_exited' in self:
    self.on_body_exited.call(body)
  if is_in_group("death"):
    self._on_body_exitedDEATH.call(body)

## don't overite - use on_body_entered instead
func _on_body_entered(body: Node2D, real=true) -> void:
  if global.player.state == global.player.States.levelLoading: return
  # if cloneEventsHere and 'on_on_body_entered' in cloneEventsHere:
  #   cloneEventsHere.on_on_body_entered(body)
  if respawning:
    if body in collisionQueue and collisionQueue[body] == "exited":
      collisionQueue.erase(body)
    else:
      collisionQueue[body] = "entered"
    return
  if 'on_body_entered' in self:
    self.on_body_entered.call(body)
  if is_in_group("death"):
    self._on_body_enteredDEATH.call(body)

## don't overite - use on_ready instead
func _ready() -> void:
  # log.pp(isChildOfCustomBlock)
  if global.player.OnPlayerFullRestart.is_connected(_ready):
    global.player.OnPlayerFullRestart.connect(_ready)
  # if !is_in_group("dontRespawnOnPlayerDeath"):
  if !global.player.OnPlayerDied.is_connected(_ready):
    global.player.OnPlayerDied.connect(respawn)

  blockOptions = {}
  if not collisionShapes:
    if get_node_or_null("CollisionShape2D"):
      collisionShapes = [$CollisionShape2D]
    elif not ignoreMissingNodes:
      log.err("collisionShapes is null", self , name)
      breakpoint
  if not EDITOR_IGNORE and not ghost:
    createEditorGhost()
  if 'generateBlockOpts' in self:
    self.generateBlockOpts.call()

  if is_in_group("attaches to things"):
    blockOptions.attachesToThings = {"type": global.PromptTypes.bool, "default": true}

  if global.useropts.allowCustomColors:
    blockOptions.color = {"type": global.PromptTypes.rgba, "default": "#fff"}
  setupOptions()
  
  __enable.call_deferred()
  respawn.call_deferred()
  if global.useropts.allowCustomColors:
    self.modulate = Color(selectedOptions.color)
  if cloneEventsHere and 'on_ready' in cloneEventsHere:
    cloneEventsHere.on_ready()
  if 'on_ready' in self:
    self.on_ready.call()

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
  if pm: return
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
  var can := CanvasLayer.new()
  add_child(can)
  pm = PopupMenu.new()
  can.add_child(pm)
  pm.system_menu_id = NativeMenu.SystemMenus.DOCK_MENU_ID
  var i := 0
  blockOptionsArray = []
  for k: String in blockOptions:
    blockOptionsArray.append(k)
    pm.add_item('', i)
    i += 1
  pm.add_item('cancel', i)
  pm.connect("index_pressed", editOption)

func editOption(idx: int) -> void:
  if idx >= len(blockOptionsArray):
    onOptionEdit.call()
    return
  # log.pp("editing", idx, blockOptions)
  var k: String = blockOptionsArray[idx]
  var newData: Variant = await global.prompt(
    k,
    blockOptions[k].type,
    selectedOptions[k],
    blockOptions[k].default,
    blockOptions[k].values if "values" in blockOptions[k] else []
  )
  log.pp(newData, "newData")
  # if !newData: return
  selectedOptions[k] = newData
  toType(k)
  respawn()
  _ready()
  onOptionEdit.call()

## don't overite - use on_physics_process instead or postMovementStep to get called after the node has moved
func _physics_process(delta: float) -> void:
  if global.player.state == global.player.States.dead: return
  if global.stopTicking: return
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
  if cloneEventsHere and 'on_physics_process' in cloneEventsHere:
    cloneEventsHere.on_physics_process(delta)
  if 'on_physics_process' in self:
    self.on_physics_process.call(delta)
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

    if not respawning:
      if collisionQueue:
        log.pp(collisionQueue, id)
        for block in collisionQueue:
          if collisionQueue[block] == "exited":
            _on_body_exited(block)
          else:
            _on_body_entered(block)
        collisionQueue = {}
      
  if cloneEventsHere and 'postMovementStep' in cloneEventsHere:
    cloneEventsHere.postMovementStep()
  if is_in_group("canBeAttachedTo"):
    for block: EditorBlock in attach_children.filter(func(e): return is_instance_valid(e)):
      if !block.thingThatMoves:
        log.err("no thingThatMoves", block.id)
        breakpoint
      if block.cloneEventsHere.following:
        block.thingThatMoves.position += (lastMovementStep / block.global_scale).rotated(-block.rotation)
      else:
        block.unusedOffset += (lastMovementStep / block.global_scale).rotated(-block.rotation)
var left_edge: float
var right_edge: float
var top_edge: float
var bottom_edge: float

func boolsToV2(u, d, l, r):
  var v = Vector2.ZERO
  if u: v.y -= 1
  if d: v.y += 1
  if l: v.x -= 1
  if r: v.x += 1
  return v

## don't overite - use on_process instead
func _process(delta: float) -> void:
  if global.player.state == global.player.States.dead: return
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

    if ghostFollowNode == self:
      ghost.rotation_degrees = 0
    else:
      ghost.global_position = ghostFollowNode.global_position
      ghost.rotation_degrees = ghostFollowNode.rotation_degrees
    ghost.use_parent_material = true
    if global.hoveredBlocks && self == global.hoveredBlocks[0] \
      or self in global.boxSelect_selectedBlocks:
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
        ghost.material.set_shader_parameter("color", Color("#6013ff"))
      else:
        # if not mouse down
        if !Input.is_action_pressed(&"editor_select"):
          if not _DISABLED:
            isBeingMoved = false
            for collider in collisionShapes:
              if not collider and not ignoreMissingNodes:
                log.pp("invalid collisionShapes", collider, collisionShapes, id)
                breakpoint
              collider.disabled = false
          # set border to hovered color
          ghost.material.set_shader_parameter("color", Color("#6e6e00"))
          # and if first hovered block, show border
          if global.hoveredBlocks && self == global.hoveredBlocks[0] \
            or self in global.boxSelect_selectedBlocks:
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

            var v = boolsToV2(onTopSide, onBottomSide, onLeftSide, onRightSide).rotated(deg_to_rad(startRotation_degrees))

            # store the selected sides in global
            global.scaleOnTopSide = v.y == -1
            global.scaleOnBottomSide = v.y == 1
            global.scaleOnRightSide = v.x == 1
            global.scaleOnLeftSide = v.x == -1
            # log.pp("ed", onLeftSide, onRightSide)

            # show what sides are being selected if editorInScaleMode and is scalable or all if selected with box select
            ghost.material.set_shader_parameter("showTop",
              self in global.boxSelect_selectedBlocks or \
              not global.editorInScaleMode or \
              (
                onTopSide and
                global.editorInScaleMode and
                (
                  is_in_group("EDITOR_OPTION_scale") or
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
                  is_in_group("EDITOR_OPTION_scale") or
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
                  is_in_group("EDITOR_OPTION_scale") or
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
                  is_in_group("EDITOR_OPTION_scale") or
                  global.useropts.allowScalingAnything
                )
              )
            )
            ghost.use_parent_material = false
          else:
            # __disable outline
            ghost.use_parent_material = true
  if 'on_process' in self:
    self.on_process.call(delta)

func createEditorGhost() -> void:
  if not ghostIconNode:
    log.err("ghost icon node is null", name)
    breakpoint
  ghost = ghostIconNode.duplicate()
  ghost.material = preload("res://scenes/blocks/selectedBorder.tres")
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
  sizeInPx = ghost.get_texture().get_size()
  # collisionShape.debug_color = Color("#5d40643f")
  collisionShape.debug_color = Color("#00000010")
  collisionShape.set_shape(rectangle)
  collider.add_child(collisionShape)
  ghost.add_child(collider)
  add_child(ghost)

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
  if cloneEventsHere and 'on_disable' in cloneEventsHere:
    cloneEventsHere.on_disable()
  _DISABLED = true
  for collider in collisionShapes:
    collider.disabled = true
  for sprite in hidableSprites:
    sprite.visible = false

## enables the node collision and shows the sprites
func __enable() -> void:
  # if not _DISABLED: return
  if cloneEventsHere and 'on_enable' in cloneEventsHere:
    cloneEventsHere.on_enable()
  _DISABLED = false
  for collider in collisionShapes:
    collider.disabled = false
  for sprite in hidableSprites:
    sprite.visible = true

# blocks
@export_group("DEATH")
func _on_body_enteredDEATH(body: Node) -> void:
  if body == global.player:
    if self not in global.player.deathSources:
      global.player.deathSources.append(self )

func _on_body_exitedDEATH(body: Node) -> void:
  if body == global.player:
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
