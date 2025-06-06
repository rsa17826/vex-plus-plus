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

@export var EDITOR_IGNORE: bool = false
@export var ghostIconNode: Sprite2D
@export var editorBarIconNode: Sprite2D
@export var collisionShapes: Array[CollisionShape2D]
@export var hidableSprites: Array[Node]
@export var cloneEventsHere: Node
@export var thingThatMoves: Node
@export var ghostFollowNode: Node = self
@export var pathFollowNode: Node

var root = self
var _DISABLED := false
var isHovered := false
var id: String
var startPosition: Vector2
var startRotation_degrees: float
var startScale: Vector2 = Vector2(1, 1)
var ghost: Node2D
var lastMovementStep: Vector2
var respawning := 0
var blockOptions: Dictionary
var selectedOptions := {}
var blockOptionsArray := []
var pm: PopupMenu

# var currentPath: PathFollow2D

func _on_mouse_entered() -> void:
  isHovered = true

func _on_mouse_exited() -> void:
  isHovered = false

func respawn() -> void:
  if not EDITOR_IGNORE:
    global_position = startPosition
    rotation_degrees = startRotation_degrees
    scale = startScale
    lastMovementStep = Vector2.ZERO
    respawning = 2

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
  if not EDITOR_IGNORE:
    if cloneEventsHere and 'on_on_input_event' in cloneEventsHere:
      cloneEventsHere.on_on_input_event(viewport, event, shape_idx)
    if last_input_event == event: return
    last_input_event = event
    # if selecting this block
    if global.hoveredBlocks && self == global.hoveredBlocks[0]:
      if !Input.is_action_pressed("editor_pan"):
        # edit block menu on rbutton
        if event.is_action_pressed("editor_edit_special") && Input.is_action_just_pressed("editor_edit_special") and not global.openMsgBoxCount:
          # log.pp(event.to_string(), shape_idx, viewport)
          if not pm: return
          # log.pp(blockOptions, event.as_text(), self, self.name)
          var i := 0
          for k: String in blockOptions:
            pm.set_item_text(i, k + ": " + global.PromptTypes.keys()[blockOptions[k].type] + " = " + str(selectedOptions[k]))
            i += 1
          pm.popup.call_deferred(Rect2i(get_screen_transform() * get_local_mouse_position(), Vector2i.ZERO))

        # select blocks when clicking them
        elif event.is_action_pressed("editor_select") && Input.is_action_just_pressed("editor_select"):
          respawn()
          global_position = startPosition
          global.selectBlock()

func _on_body_exited(body: Node2D) -> void:
  if global.player.state == global.player.States.dead and body == global.player: return
  if 'on_body_exited' in self:
    self.on_body_exited.call(body)
  if is_in_group("death"):
    self._on_body_exitedDEATH.call(body)

func _on_body_entered(body: Node2D) -> void:
  # if cloneEventsHere and 'on_on_body_entered' in cloneEventsHere:
  #   cloneEventsHere.on_on_body_entered(body)
  if global.player.state == global.player.States.dead and body == global.player: return
  if 'on_body_entered' in self:
    self.on_body_entered.call(body)
  if is_in_group("death"):
    self._on_body_enteredDEATH.call(body)

func _ready() -> void:
  if not EDITOR_IGNORE:
    if _ready not in global.player.OnPlayerFullRestart:
      global.player.OnPlayerFullRestart.append(_ready)
    if is_in_group("respawnOnPlayerDeath"):
      if _ready not in global.player.OnPlayerDied:
        global.player.OnPlayerDied.append(_ready)

    blockOptions = {}
    if not collisionShapes:
      if get_node_or_null("CollisionShape2D"):
        collisionShapes = [$CollisionShape2D]
      else:
        log.err("collisionShapes is null", self, name)
        breakpoint
    if not ghost:
      createEditorGhost()
    if 'generateBlockOpts' in self:
      self.generateBlockOpts.call()

    if is_in_group("attaches to things"):
      blockOptions.attachesToThings = {"type": global.PromptTypes.bool, "default": true}

    if global.useropts.allowCustomColors:
      blockOptions.color = {"type": global.PromptTypes.string, "default": "#fff"}
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
    global.PromptTypes.singleArr:
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
    if "default" in blockOptions[opt]:
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
  if idx >= len(blockOptionsArray): return
  # log.pp("editing", idx, blockOptions)
  var k: Variant = blockOptionsArray[idx]
  var newData: Variant = await global.prompt(k, blockOptions[k].type, selectedOptions[k], blockOptions[k].values if "values" in blockOptions[k] else [])
  log.pp(newData, "newData")
  # if !newData: return
  selectedOptions[k] = newData
  toType(k)
  respawn()
  _ready()

func _physics_process(delta: float) -> void:
  if global.openMsgBoxCount: return
  if global.selectedBlock == self && Input.is_action_pressed("editor_select"): return
  var lastpos: Vector2 = thingThatMoves.global_position if thingThatMoves else global_position
  # 
  if is_in_group("updown"):
    _physics_processUPDOWN(delta)
  if is_in_group("downup"):
    _physics_processDOWNUP(delta)
  if is_in_group("leftright"):
    _physics_processLEFTRIGHT(delta)
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
  if not EDITOR_IGNORE:
    if respawning:
      lastMovementStep = Vector2.ZERO
    else:
      if thingThatMoves:
        lastMovementStep = thingThatMoves.global_position - lastpos
      else:
        lastMovementStep = global_position - lastpos
    if respawning:
      respawning -= 1
    if cloneEventsHere and 'postMovementStep' in cloneEventsHere:
      cloneEventsHere.postMovementStep()

func _process(delta: float) -> void:
  if not EDITOR_IGNORE:
    if global.openMsgBoxCount: return
    if global.player.state == global.player.States.dead:
      respawn()
      return
    if is_in_group("buzsaw - generic"):
      _processBUZSAW_GENERIC(delta)

    if isHovered:
      if self not in global.hoveredBlocks:
        global.hoveredBlocks.append(self)
    else:
      if self in global.hoveredBlocks:
        global.hoveredBlocks.erase(self)

    if ghostFollowNode == self:
      ghost.rotation_degrees = 0
    else:
      ghost.global_position = ghostFollowNode.global_position
      ghost.rotation_degrees = ghostFollowNode.rotation_degrees
    ghost.use_parent_material = true
    ghost.self_modulate.a = global.useropts.blockGhostAlpha

    ghost.visible = global.showEditorUi
    if global.showEditorUi and not Input.is_action_pressed("editor_pan"):
      if global.selectedBlock == self:
        if Input.is_action_pressed("editor_select"):
          global_position = startPosition
        for collider in collisionShapes:
          if not collider:
            log.pp(collider, collisionShapes, id)
            breakpoint
          collider.disabled = true
        ghost.use_parent_material = false
        ghost.material.set_shader_parameter("color", Color("#6013ff"))
      else:
        # if not mouse down
        if !Input.is_action_pressed("editor_select"):
          if not _DISABLED:
            for collider in collisionShapes:
              if not collider:
                log.pp("invalid collisionShapes", collider, collisionShapes, id)
                breakpoint
              collider.disabled = false
          # set border to hovered color
          ghost.material.set_shader_parameter("color", Color("#6e6e00"))
          # and if first hovered block, show border
          if global.hoveredBlocks && self == global.hoveredBlocks[0]:
            var mouse_pos := get_global_mouse_position()

            var node_pos := ghost.global_position
            var node_size: Vector2 = ghost.texture.get_size() * ghost.scale * scale
            var left_edge := node_pos.x - node_size.x / 2
            var right_edge := node_pos.x + node_size.x / 2
            var top_edge := node_pos.y - node_size.y / 2
            var bottom_edge := node_pos.y + node_size.y / 2

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

            # store the selected sides in global
            global.scaleOnTopSide = onTopSide
            global.scaleOnBottomSide = onBottomSide
            global.scaleOnRightSide = onRightSide
            global.scaleOnLeftSide = onLeftSide

            # show what sides are being selected if editorInScaleMode and is scalable
            ghost.material.set_shader_parameter("showTop",
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
  # collisionShape.debug_color = Color("#5d40643f")
  collisionShape.debug_color = Color("#00000010")
  collisionShape.set_shape(rectangle)
  collider.add_child(collisionShape)
  ghost.add_child(collider)
  add_child(ghost)

func spin(speed: float, node: Node2D = self) -> void:
  node.rotation_degrees = fmod(global.tick * speed, 360.0)

func getTexture(node: Node2D) -> String:
  return global.regMatch(node.texture.resource_path, r'/([^/]+)\.png$')[1].strip_edges()

func setTexture(node: Node, newTexture: String) -> void:
  node.texture = load(global.regReplace(node.texture.resource_path, '/[^/]+$', '/' + str(newTexture) + '.png'))

func __disable() -> void:
  if _DISABLED: return
  if cloneEventsHere and 'on__disable' in cloneEventsHere:
    cloneEventsHere.on__disable()
  _DISABLED = true
  for collider in collisionShapes:
    collider.disabled = true
  for sprite in hidableSprites:
    sprite.visible = false

func __enable() -> void:
  if not _DISABLED: return
  if cloneEventsHere and 'on__enable' in cloneEventsHere:
    cloneEventsHere.on__enable()
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
      global.player.deathSources.append(self)

func _on_body_exitedDEATH(body: Node) -> void:
  if body == global.player:
    if self in global.player.deathSources:
      global.player.deathSources.erase(self)

@export_group("BUZSAW - GENERIC")
@export var BUZSAW_GENERIC_spriteToRotateRight: Sprite2D
@export var BUZSAW_GENERIC_spriteToRotateLeft: Sprite2D
func _processBUZSAW_GENERIC(delta: float) -> void:
  var speed = 80.0
  spin(speed, BUZSAW_GENERIC_spriteToRotateRight)
  spin(-speed, BUZSAW_GENERIC_spriteToRotateLeft)

@export_group("MOVING BLOCKS")
@export var MOVING_BLOCKS_nodeToMove: Node2D

func _physics_processLEFTRIGHT(delta: float) -> void:
  MOVING_BLOCKS_nodeToMove.global_position.x = startPosition.x - sin(global.tick * 1.5) * 200
func _physics_processUPDOWN(delta: float) -> void:
  MOVING_BLOCKS_nodeToMove.global_position.y = startPosition.y + sin(global.tick * 1.5) * 200
func _physics_processDOWNUP(delta: float) -> void:
  MOVING_BLOCKS_nodeToMove.global_position.y = startPosition.y - sin(global.tick * 1.5) * 200
