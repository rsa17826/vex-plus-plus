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
# @name auto add export_group
# @regex ^# ([\w ]{2,20})\n(?!@export_group)
# @replace $&@export_group("$1")
#
# @flags gm
# @endregex

@export var ghostIconNode: Sprite2D
@export var editorBarIconNode: Sprite2D
@export var collisionShapes: Array[CollisionShape2D]
@export var hidableSprites: Array[Node]
@export var cloneEventsHere: Node
@export var thingThatMoves: Node
@export var ghostFollowNode: Node = self

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

func _on_mouse_entered() -> void:
  isHovered = true

func _on_mouse_exited() -> void:
  isHovered = false

func respawn() -> void:
  global_position = startPosition
  rotation_degrees = startRotation_degrees
  scale = startScale
  FALLING_falling = false
  BOUNCY_bounceState = 0
  BOUNCY_bouncing = false
  BOUNCY_bounceForce = 0
  KEY_following = false
  FALLING_SPIKE_falling = false
  lastMovementStep = Vector2.ZERO
  respawning = 2
  SPEED_UP_LEVER_colliding = false
  GRAV_UP_LEVER_colliding = false
  GRAV_DOWN_LEVER_colliding = false
  if self in global.player.keys:
    global.player.keys.erase(self)
  if cloneEventsHere and 'on_respawn' in cloneEventsHere:
    cloneEventsHere.on_respawn()

var onBottomSide := false
var onTopSide := false
var onLeftSide := false
var onRightSide := false

var last_input_event: InputEvent
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
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
  if cloneEventsHere and '_on_body_exited' in cloneEventsHere:
    cloneEventsHere.on_on_body_exited(body)
  if is_in_group("water"):
    _on_body_exitedWATER(body)
  if is_in_group("targeting laser"):
    _on_body_exitedTARGETING_LASER(body)
  if is_in_group("speed up lever"):
    _on_body_exitedSPEED_UP_LEVER(body)
  if is_in_group("grav up lever"):
    _on_body_exitedGRAV_UP_LEVER(body)
  if is_in_group("grav down lever"):
    _on_body_exitedGRAV_DOWN_LEVER(body)
  if is_in_group("death"):
    _on_body_exitedDEATH(body)

func _on_body_entered(body: Node2D) -> void:
  if cloneEventsHere and 'on_on_body_entered' in cloneEventsHere:
    cloneEventsHere.on_on_body_entered(body)
  if global.player.state == global.player.States.dead and body == global.player: return
  if is_in_group("water"):
    _on_body_enteredWATER(body)
  if is_in_group("death"):
    _on_body_enteredDEATH(body)
  if is_in_group("goal"):
    _on_body_enteredGOAL(body)
  if is_in_group("checkpoint"):
    _on_body_enteredCHECKPOINT(body)
  if is_in_group("cannon"):
    _on_body_enteredCANON(body)
  if is_in_group("speed up lever"):
    _on_body_enteredSPEED_UP_LEVER(body)
  if is_in_group("grav up lever"):
    _on_body_enteredGRAV_UP_LEVER(body)
  if is_in_group("grav down lever"):
    _on_body_enteredGRAV_DOWN_LEVER(body)
  if is_in_group("invis"):
    _on_body_enteredINVIS(body)
  if is_in_group("key"):
    _on_body_enteredKEY(body)
  if is_in_group("laser"):
    _on_body_enteredLASER(body)
  if is_in_group("light switch"):
    _on_body_enteredLIGHT_SWITCH(body)
  if is_in_group("pole"):
    _on_body_enteredPOLE(body)
  if is_in_group("star"):
    _on_body_enteredSTAR(body)
  if is_in_group("targeting laser"):
    _on_body_enteredTARGETING_LASER(body)

func _ready() -> void:
  if cloneEventsHere and 'on_ready' in cloneEventsHere:
    cloneEventsHere.on_ready()
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
  if is_in_group("goal"):
    blockOptions.requiredLevelCount = {"type": global.PromptTypes.int, "default": 0}
  if is_in_group("checkpoint"):
    blockOptions.multiUse = {"type": global.PromptTypes.bool, "default": false}
  if is_in_group("inner level"):
    blockOptions.level = {"type": global.PromptTypes.string, "default": ""}
    blockOptions.requiredLevelCount = {"type": global.PromptTypes.int, "default": 0}
  if is_in_group("attaches to things"):
    blockOptions.attachesToThings = {"type": global.PromptTypes.bool, "default": true}
  if is_in_group("pulley"):
    blockOptions.direction = {"type": global.PromptTypes.singleArr, "default": "right", "values": [
      "left",
      "right",
      "user"
    ]}
  if global.useropts.allowCustomColors:
    blockOptions.color = {"type": global.PromptTypes.string, "default": "#fff"}
  setupOptions()

  if is_in_group("goal"):
    _readyGOAL()
  if is_in_group("inner level"):
    _readyINNER_LEVEL()
  if is_in_group("checkpoint"):
    _readyCHECKPOINT()
  if is_in_group("star"):
    _readySTAR()
  if is_in_group("10x spike"):
    _ready10X_SPIKE()
  __enable.call_deferred()
  respawn.call_deferred()
  if global.useropts.allowCustomColors:
    self.modulate = Color(selectedOptions.color)

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
  if is_in_group("10x spike"):
    # so i am just setting it here instead
    $Node2D.position = Vector2.ZERO
  if is_in_group("updown"):
    _physics_processUPDOWN(delta)
  if is_in_group("downup"):
    _physics_processDOWNUP(delta)
  if is_in_group("leftright"):
    _physics_processLEFTRIGHT(delta)
  if is_in_group("water"):
    _physics_processWATER(delta)
  if is_in_group("rotating buzsaw"):
    _physics_processROTATING_BUZSAW(delta)
  if is_in_group("solar"):
    _physics_processSOLAR(delta)
  if is_in_group("scythe"):
    _physics_processSCYTHE(delta)
  if is_in_group("spark"):
    _physics_processSPARK(delta)
  if is_in_group("closing spikes"):
    _physics_processCLOSING_SPIKES(delta)
  if is_in_group("quadrant"):
    _physics_processQUADRANT(delta)
  if is_in_group("falling spike"):
    _physics_processFALLING_SPIKE(delta)
  if cloneEventsHere and 'on_physics_process' in cloneEventsHere:
    cloneEventsHere.on_physics_process(delta)
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
  if global.openMsgBoxCount: return
  if global.player.state == global.player.States.dead:
    respawn()
    return
  if is_in_group("buzsaw - generic"):
    _processBUZSAW_GENERIC(delta)
  # if is being hovered is not same as global hovered list, fix it
  if isHovered:
    if self not in global.hoveredBlocks:
      global.hoveredBlocks.append(self)
  else:
    if self in global.hoveredBlocks:
      global.hoveredBlocks.erase(self)

  if ghostFollowNode != self:
    ghost.global_position = ghostFollowNode.global_position
    ghost.rotation_degrees = ghostFollowNode.rotation_degrees
  else:
    ghost.rotation_degrees = 0
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

  if is_in_group("bouncy"):
    _processBOUNCY(delta)
  if is_in_group("key"):
    _processKEY(delta)

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
  # visible = true

# all blocks
@export_group("all blocks")
@export_category("BLOCKS")

# water
@export_group("WATER")

const MAX_WATER_REENTER_TIME = 7

var waterReenterTimer: float = 0

var WATER_playerInsideWater := false

func _physics_processWATER(delta: float) -> void:
  # lower frame counters
  if waterReenterTimer > 0:
    waterReenterTimer -= delta * 60

  if WATER_playerInsideWater:
    if self not in global.player.inWaters and waterReenterTimer <= 0:
      global.player.inWaters.append(self)
  elif self in global.player.inWaters:
    global.player.inWaters.erase(self)

func _on_body_exitedWATER(body: Node) -> void:
  if body == global.player:
    WATER_playerInsideWater = false
    waterReenterTimer = MAX_WATER_REENTER_TIME

func _on_body_enteredWATER(body: Node) -> void:
  if body == global.player:
    WATER_playerInsideWater = true

# falling
@export_group("FALLING")

var FALLING_falling := false

# updown
@export_group("UPDOWN")
@export var UPDOWN_nodeToMove: Node2D

func _physics_processUPDOWN(delta: float) -> void:
  UPDOWN_nodeToMove.global_position.y = startPosition.y + sin(global.tick * 1.5) * 200

# downup
@export_group("DOWNUP")
@export var DOWNUP_nodeToMove: Node2D

func _physics_processDOWNUP(delta: float) -> void:
  DOWNUP_nodeToMove.global_position.y = startPosition.y - sin(global.tick * 1.5) * 200

# leftright
@export_group("LEFTRIGHT")
@export var LEFTRIGHT_nodeToMove: Node2D
var wasColliding := false
func _physics_processLEFTRIGHT(delta: float) -> void:
  LEFTRIGHT_nodeToMove.global_position.x = startPosition.x - sin(global.tick * 1.5) * 200

# bouncy
@export_group("BOUNCY")
var BOUNCY_bouncing := false
var BOUNCY_bounceState: float = 0
var BOUNCY_bounceForce: float = 0

func BOUNCY_start() -> void:
  if BOUNCY_bouncing: return
  BOUNCY_bouncing = true
  BOUNCY_bounceState = 0
  global.player.state = global.player.States.bouncing

func _processBOUNCY(delta: float) -> void:
  if respawning: return
  if BOUNCY_bouncing:
    if not BOUNCY_bounceForce:
      BOUNCY_bounceForce = (scale.y * 7) * -2900
    if BOUNCY_bounceState < 100:
      # increase the bounce state more the farther from 50 the state is
      BOUNCY_bounceState += max(.2, abs(BOUNCY_bounceState - 50) / 10.0) * delta * 300 / (scale.y * 21)
    else:
      # when the bouncing animation is done start bouncing the player
      global.player.vel['bounce'] = Vector2(0, BOUNCY_bounceForce)
      global.player.justAddedVels['bounce'] = 3
      global.player.state = global.player.States.jumping
      respawn()
    if BOUNCY_bounceState <= 50:
      # start by going down
      var size: Vector2 = ghost.texture.get_size() * startScale
      global_position.y = global.rerange(BOUNCY_bounceState, 0, 50, startPosition.y, startPosition.y + (size.y / 4.0))
      scale.y = global.rerange(BOUNCY_bounceState, 0, 50, startScale.y, startScale.y / 2)
    else:
      # then go back up
      var size: Vector2 = ghost.texture.get_size() * startScale
      scale.y = global.rerange(BOUNCY_bounceState, 50, 100, startScale.y / 2, startScale.y)
      global_position.y = global.rerange(BOUNCY_bounceState, 100, 50, startPosition.y, startPosition.y + (size.y / 4.0))

    var node_pos := ghostIconNode.global_position
    var node_size := ghostIconNode.texture.get_size() * scale
    var top_edge := node_pos.y - node_size.y / 2

    var playerGhost: Node2D = global.player.get_parent().ghost
    var playerGhostSize: Vector2 = playerGhost.get_texture().get_size() * playerGhost.scale

    # move the player to the top center of the bouncy block
    global.player.global_position.y = top_edge - (playerGhostSize.y / 2)
    # global.player.global_position.x = node_pos.x

# death
@export_group("DEATH")
func _on_body_enteredDEATH(body: Node) -> void:
  if body == global.player:
    if self not in global.player.deathSources:
      global.player.deathSources.append(self)

func _on_body_exitedDEATH(body: Node) -> void:
  if body == global.player:
    if self in global.player.deathSources:
      global.player.deathSources.erase(self)

# inner level
@export_group("INNER LEVEL")
@export var INNER_LEVEL_label: Node
@export var INNER_LEVEL_sprite: Node2D
var INNER_LEVEL_disabled := false

func INNER_LEVEL_enterLevel() -> void:
  if INNER_LEVEL_disabled: return
  global.loadInnerLevel(selectedOptions.level)

func _readyINNER_LEVEL() -> void:
  INNER_LEVEL_disabled = false
  var text: String = selectedOptions.level + "\nNEW"
  if not selectedOptions.level:
    text = "no level set"
    INNER_LEVEL_disabled = true
  elif not global.file.isFile(global.path.join(global.levelFolderPath, selectedOptions.level + '.sds')):
    text = "invalid level\n" + selectedOptions.level
    INNER_LEVEL_disabled = true
  elif selectedOptions.requiredLevelCount > len(global.beatLevels):
    text = "beat " + str(selectedOptions.requiredLevelCount - len(global.beatLevels)) + " more levels"
    INNER_LEVEL_disabled = true
  elif selectedOptions.level in global.beatLevels.map(func(e: Dictionary) -> String:
    return e.name
    ):
    text = selectedOptions.level + "\nCOMPLETED"
  elif selectedOptions.level == global.currentLevel().name:
    text = "same as current level\n" + selectedOptions.level
    INNER_LEVEL_disabled = true
  elif selectedOptions.level not in global.levelOpts.stages:
    text = "level settings not found\n" + selectedOptions.level
    INNER_LEVEL_disabled = true
  elif selectedOptions.level in global.loadedLevels.map(func(e: Dictionary) -> String:
    return e.name
    ):
    text = "level already in path"
    INNER_LEVEL_disabled = true
  INNER_LEVEL_label.text = text

# goal
@export_group("GOAL")
@export var GOAL_sprite: Node2D
@export var GOAL_CollisionShape: Node2D
func _readyGOAL() -> void:
  if selectedOptions.requiredLevelCount > len(global.beatLevels):
    GOAL_sprite.modulate = Color("#555")
    GOAL_CollisionShape.disabled = true

func _on_body_enteredGOAL(body: Node) -> void:
  if body == global.player:
    if selectedOptions.requiredLevelCount > len(global.beatLevels): return
    global.win()

# checkpoint
@export_group("CHECKPOINT")
@export var CHECKPOINT_sprite: Node2D
func _on_body_enteredCHECKPOINT(body: Node) -> void:
  if body == global.player and (getTexture(CHECKPOINT_sprite) == '1' or selectedOptions.multiUse):
    global.savePlayerLevelData()
    global.player.lastSpawnPoint = startPosition - global.player.get_parent().global_position
    global.player.lightsOut = false
    setTexture(CHECKPOINT_sprite, "2")
    global.checkpoints = global.checkpoints.filter(func(e: Variant) -> bool:
      return is_instance_valid(e))
    for checkpoint in global.checkpoints:
      if checkpoint == self: continue
      if getTexture(checkpoint.CHECKPOINT_sprite) == '2':
        setTexture(checkpoint.CHECKPOINT_sprite, '1' if checkpoint.selectedOptions.multiUse else '3')

func _readyCHECKPOINT() -> void:
  if not self in global.checkpoints:
    global.checkpoints.append(self)
  setTexture(CHECKPOINT_sprite, "1")

# rotating buzsaw
@export_group("ROTATING BUZSAW")
@export var ROTATING_BUZSAW_nodeToSpin: Node2D
func _physics_processROTATING_BUZSAW(delta: float) -> void:
  spin(300, ROTATING_BUZSAW_nodeToSpin)

# scythe
@export_group("SCYTHE")
@export var SCYTHE_nodeToSpin: Node2D
func _physics_processSCYTHE(delta: float) -> void:
  spin(-300, SCYTHE_nodeToSpin)

# canon
@export_group("CANON")
func _on_body_enteredCANON(body: Node) -> void:
  if body == global.player:
    global.player.state = global.player.States.inCannon
    global.player.global_position = ghostIconNode.global_position

# speed up lever
@export_group("SPEED UP LEVER")
var SPEED_UP_LEVER_colliding := false

func _on_body_enteredSPEED_UP_LEVER(body: Node) -> void:
  SPEED_UP_LEVER_colliding = true
func _on_body_exitedSPEED_UP_LEVER(body: Node) -> void:
  SPEED_UP_LEVER_colliding = false

# gravity up lever
@export_group("GRAVITY UP LEVER")
var GRAV_UP_LEVER_colliding := false

func _on_body_enteredGRAV_UP_LEVER(body: Node) -> void:
  if body == global.player:
    GRAV_UP_LEVER_colliding = true
func _on_body_exitedGRAV_UP_LEVER(body: Node) -> void:
  if body == global.player:
    GRAV_UP_LEVER_colliding = false

# gravity down lever
@export_group("GRAVITY DOWN LEVER")
var GRAV_DOWN_LEVER_colliding := false

func _on_body_enteredGRAV_DOWN_LEVER(body: Node) -> void:
  if body == global.player:
    GRAV_DOWN_LEVER_colliding = true
func _on_body_exitedGRAV_DOWN_LEVER(body: Node) -> void:
  if body == global.player:
    GRAV_DOWN_LEVER_colliding = false

func _input(event: InputEvent) -> void:
  if Input.is_action_just_pressed("down"):
    if is_in_group("grav down lever"):
      if GRAV_DOWN_LEVER_colliding and global.player.state != global.player.States.pullingLever:
        global.player.state = global.player.States.pullingLever
        if global.player.gravState == global.player.GravStates.down:
          global.player.gravState = global.player.GravStates.normal
        else:
          global.player.gravState = global.player.GravStates.down

    if is_in_group("grav up lever"):
      if GRAV_UP_LEVER_colliding and global.player.state != global.player.States.pullingLever:
        global.player.state = global.player.States.pullingLever
        if global.player.gravState == global.player.GravStates.up:
          global.player.gravState = global.player.GravStates.normal
        else:
          global.player.gravState = global.player.GravStates.up

# key
@export_group("KEY")
var KEY_following := false
func _on_body_enteredKEY(body: Node) -> void:
  if body == global.player and not KEY_following and not self in global.player.keys:
    global.player.keys.append(self)
    log.pp("key added", self)
    KEY_following = true

func _processKEY(delta: float) -> void:
  if !KEY_following: return
  global_position = global.player.global_position

# invis
@export_group("INVIS")
func _on_body_enteredINVIS(body: Node) -> void:
  pass

# laser
@export_group("LASER")
func _on_body_enteredLASER(body: Node) -> void:
  pass

# light switch
@export_group("LIGHT SWITCH")
func _on_body_enteredLIGHT_SWITCH(body: Node) -> void:
  if body == global.player:
    global.player.lightsOut = true

# locked box
@export_group("LOCKED_BOX")
# boxes can only be unlocked once per frame to prevent excessive key usage
var LOCKED_BOX_unlocked := false
func LOCKED_BOX_unlock() -> void:
  if len(global.player.keys) and not LOCKED_BOX_unlocked:
    LOCKED_BOX_unlocked = true
    log.pp(global.player.keys)
    var key: Node2D = global.player.keys.pop_back()
    key.__disable()
    __disable()
    await global.wait()
    LOCKED_BOX_unlocked = false

# solar
@export_group("SOLAR")
func _physics_processSOLAR(delta: float) -> void:
  if global.player.lightsOut:
    __disable()
  else:
    __enable()

# POLE
@export_group("POLE")
func _on_body_enteredPOLE(body: Node) -> void:
  if global.player.state != global.player.States.swingingOnPole:
    global.player.state = global.player.States.swingingOnPole

# PULLEY
@export_group("PULLEY")

# star
@export_group("STAR")
func _readySTAR() -> void:
  # log.pp(global.currentLevel().foundStar, global.currentLevel())
  if global.currentLevel().foundStar:
    await global.wait()
    __disable.call_deferred()

func _on_body_enteredSTAR(body: Node) -> void:
  if body == global.player:
    __disable.call_deferred()
    global.starFound()

# spark
@export_group("SPARK")
func _physics_processSPARK(delta: float) -> void:
  pass

# TARGETING_LASER
@export_group("TARGETING_LASER")
func _on_body_enteredTARGETING_LASER(body: Node) -> void:
  pass
func _on_body_exitedTARGETING_LASER(body: Node) -> void:
  pass

# CLOSING_SPIKES
@export_group("CLOSING_SPIKES")
@export var CLOSING_SPIKES_leftCollisionShape: CollisionShape2D
@export var CLOSING_SPIKES_rightCollisionShape: CollisionShape2D
@export var CLOSING_SPIKES_leftSprite: Sprite2D
@export var CLOSING_SPIKES_rightSprite: Sprite2D

func _physics_processCLOSING_SPIKES(delta: float) -> void:
  rotation_degrees = 0
  CLOSING_SPIKES_leftCollisionShape.global_position = startPosition + %collisionNode.global_position - global_position
  CLOSING_SPIKES_rightCollisionShape.global_position = startPosition + %collisionNode.global_position - global_position

  var newOffset := global.animate(80, [
    {
      "until": 120,
      "from": - 189.0,
      "to": - 400.0
    },
    {
      "until": 130,
      "from": - 400.0,
      "to": - 189.0
    },
    {
      "until": 160,
      "from": - 189.0,
      "to": - 189.0
    }
  ]) * scale.x

  CLOSING_SPIKES_leftCollisionShape.global_position.x += newOffset
  CLOSING_SPIKES_leftSprite.global_position.x = CLOSING_SPIKES_leftCollisionShape.global_position.x
  CLOSING_SPIKES_rightCollisionShape.global_position.x -= newOffset
  CLOSING_SPIKES_rightSprite.global_position.x = CLOSING_SPIKES_rightCollisionShape.global_position.x
  rotation_degrees = startRotation_degrees

# QUADRANT
@export_group("QUADRANT")
@export var QUADRANT_nodeToSpin: Node2D
func _physics_processQUADRANT(delta: float) -> void:
  spin(150, QUADRANT_nodeToSpin)

# 10X_SPIKE
@export_group("10X_SPIKE")
func _ready10X_SPIKE() -> void:
  # just setting it here doesnt work and i cant figure out why
  # $Node2D.position = Vector2.ZERO
  # await global.wait(1000)
  # $Node2D.position = Vector2.ZERO
  pass

# buzsaw - generic
@export_group("BUZSAW - GENERIC")
@export var BUZSAW_GENERIC_spriteToRotateRight: Sprite2D
@export var BUZSAW_GENERIC_spriteToRotateLeft: Sprite2D
func _processBUZSAW_GENERIC(delta: float) -> void:
  var speed = 80.0
  spin(speed, BUZSAW_GENERIC_spriteToRotateRight)
  spin(-speed, BUZSAW_GENERIC_spriteToRotateLeft)

# falling spike
@export_group("FALLING SPIKE")
@export var FALLING_SPIKE_nodeToFall: Node2D
var FALLING_SPIKE_falling: bool = false
func _physics_processFALLING_SPIKE(delta: float) -> void:
  var speed = 300.0
  if FALLING_SPIKE_falling:
    position += Vector2(0, -speed * delta).rotated(rotation)
