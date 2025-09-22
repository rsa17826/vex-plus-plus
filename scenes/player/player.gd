@icon("res://scenes/player/images/anim/idle/1.png")
extends CharacterBody2D
class_name Player

@export var root: EditorBlock
@export var stickyFloorDetector: Area2D
@export var mainCollisionShape2D: CollisionShape2D
@export var nowjDetector: Area2D
@export var respawnDetectionArea: Area2D
@export var leftWallDetection: RayCast2D
@export var rightWallDetection: RayCast2D
@export var leftWallTopDetection: RayCast2D
@export var rightWallTopDetection: RayCast2D
@export var waterRay: RayCast2D
@export var deathDetectors: Node2D
@export var wallDetectors: Node2D
@export var anim: AnimatedSprite2D
@export var waterAnimTop: AnimatedSprite2D
@export var waterAnimBottom: AnimatedSprite2D
@export var camera: Camera2D

var MAX_JUMP_COUNT = 0
var DEATH_TIME = 20
const GRAVITY = 1280
const MAX_PULLEY_NO_DIE_TIME = 50
const MOVESPEED = 220
const JUMP_POWER = -430
const MAX_WALL_SLIDE_FRAMES = 120
const MAX_SLIDE_RECOVER_TIME = 14
const MAX_WALL_BREAK_FROM_DOWN_FRAMES = 10
const MAX_KT_TIMER = 6
const MAX_WATER_KT_TIMER = 6
const WATER_TURNSPEED = 170
const WATER_MOVESPEED = 4000
const WATER_EXIT_BOUNCE_FORCE = -600
const WALL_SLIDE_SPEED = 35
const MAX_BOX_KICK_RECOVER_TIME = 22
const MAX_POLE_COOLDOWN = 4
const MAX_ZIPLINE_COOLDOWN = 17
const SMALL = .00001

var ziplineCooldown := 0.0
var lastDeathWasForced := false
var respawnCooldown: float = 0
var levelFlags: Dictionary[String, Variant] = {}
var autoRunDirection: int = 1
var cannonRotationDelayFrames: float = 0
var remainingJumpCount: int = 0
var poleCooldown: float = 0
var deathSources: Array[EditorBlock] = []
var targetingLasers: Array[BlockTargetingLaser] = []
var heat: float = 0.0
var pulleyNoDieTimer: float = 0
var currentRespawnDelay: float = 0
var activePulley: BlockPulley = null
var activePole: Node2D = null
var playerXIntent: float = 0
var lastWallCollisionPoint: Variant
var lastWall: EditorBlock
var lastWallSide := 0
var breakFromWall := false
var state := States.levelLoading
var wallSlidingFrames: float = 0
var slideRecovery: float = 0
var boxKickRecovery: float = 0
var duckRecovery: float = 0
var wallBreakDownFrames: float = 0
var playerKT: float = 0
var wasJustInWater := false
var camLockPos: Vector2
var deadTimer: float = 0
var currentHungWall: Variant = 0
var hungWallSide := 0
var deathPosition := Vector2.ZERO
var speedLeverActive: bool = false
var slowCamRot := true
var camRotLock: float = 0
var activeCannon: BlockCannon
var activeZipline: BlockZipline
var targetZipline: BlockZipline

var lightsOut: bool = false

var keys: Array[Node2D] = []:
  get():
    keys = keys.filter(global.isAlive)
    return keys

var collsiionOn_top := []
var collsiionOn_bottom := []
var collsiionOn_left := []
var collsiionOn_right := []

var lastSpawnPoint := Vector2.ZERO
var tempLastSpawnPoint := Vector2.ZERO

var moving := 0

var velTotal: Vector2:
  get():
    var v := Vector2.ZERO
    for k in vel:
      v += vel[k]
    return v

var inWaters: Array[BlockWater] = []:
  get():
    inWaters = inWaters.filter(global.isAlive)
    return inWaters

var ACTIONjump: bool = false:
  get():
    if ACTIONjump:
      ACTIONjump = false
      return true
    return ACTIONjump

var vel: Dictionary[String, Vector2] = {
  "pole": Vector2.ZERO,
  "user": Vector2.ZERO,
  "waterExit": Vector2.ZERO,
  "bounce": Vector2.ZERO,
  "conveyer": Vector2.ZERO,
  "cannon": Vector2.ZERO,
  "zipline": Vector2.ZERO,
}
var velDecay := {
  "pole": 1,
  "user": 1,
  "waterExit": .9,
  "cannon": .9,
  "bounce": 0.95,
  "conveyer": .9,
  "zipline": .95,
}
var justAddedVels := {
  "pole": 0,
  "user": 0,
  "waterExit": 0,
  "bounce": 0,
  "conveyer": 0,
  "cannon": 0,
  "zipline": 0,
}
var stopVelOnGround := ["bounce", "waterExit", "cannon", "pole", "zipline"]
var stopVelOnWall := ["bounce", "waterExit", "cannon", "pole", "conveyer", "zipline"]
var stopVelOnCeil := ["bounce", "waterExit", "cannon", "pole"]

@onready var unduckSize: Vector2 = Vector2(8, 33) # mainCollisionShape2D.shape.size
@onready var unduckPos: Vector2 = Vector2.ZERO # mainCollisionShape2D.position

var mouseMode := Input.MOUSE_MODE_CONFINED_HIDDEN

enum States {
  idle,
  moving,
  jumping,
  wallHang,
  falling,
  wallSliding,
  sliding,
  dead,
  bouncing,
  inCannon,
  pullingLever,
  swingingOnPole,
  onPulley,
  pushing,
  onZipline,
  levelLoading,
}

var isFakeMouseMovement: bool = false

var gravState: GravStates = GravStates.normal
enum GravStates {
  up,
  down,
  normal
}

func _init() -> void:
  global.player = self

func _ready() -> void:
  anim.use_parent_material = false
  DEATH_TIME = max(5, global.useropts.playerRespawnTime)
  Input.mouse_mode = mouseMode
  global.gravChanged.connect(func(lastUpDir, newUpDir):
    for v in vel:
      vel[v]=vel[v].rotated(angle_difference(lastUpDir.angle(), newUpDir.angle()))
  )

var defaultAngle: float
var startedPanning: bool = false

func _unhandled_input(event: InputEvent) -> void:
  if get_viewport().gui_get_focus_owner(): return
  if global.tabMenu.visible: return
  if global.openMsgBoxCount: return
  if Input.is_action_just_pressed(&"save_current_location_as_last_checkpoint", true):
    lastSpawnPoint = (global_position - root.global_position)
  if Input.is_action_just_pressed(&"restart", true):
    die(DEATH_TIME, false, true)
  if Input.is_action_just_pressed(&"full_restart", true):
    die(DEATH_TIME, true, true)

  if state != States.dead and global.showEditorUi:
    if Input.is_action_just_pressed(&"focus_on_player", true):
      global.setEditorUiState(false)
      camLockPos = Vector2.ZERO
      camera.position = Vector2.ZERO

  var shouldPan: bool = Input.is_action_pressed(&"editor_pan")
  if global.useropts.autoPanWhenClickingEmptySpace:
    if not Input.is_action_pressed(&"editor_pan"):
      if (
        !global.hoveredBlocks
        or startedPanning
      ) \
      and !global.selectedBlock \
      and Input.is_action_pressed(&"editor_select", true) \
      :
        startedPanning = true
        shouldPan = true
      else:
        startedPanning = false
      if !Input.is_action_pressed(&"editor_select", true):
        startedPanning = false
        shouldPan = false

  if event is InputEventMouseMotion and event.relative == Vector2.ZERO: return
  if event is InputEventMouseMotion and isFakeMouseMovement:
    isFakeMouseMovement = false
    return
  # log.pp(event.to_string(), global.showEditorUi)
  if global.openMsgBoxCount: return
  if event is InputEventMouseMotion and not global.showEditorUi:
    camRotLock = defaultAngle
    global.setEditorUiState(true)
  if shouldPan and not global.showEditorUi:
    camRotLock = defaultAngle
    global.setEditorUiState(true)
    if not camLockPos:
      camLockPos = camera.global_position
    Input.set_default_cursor_shape(Input.CURSOR_DRAG)
  else:
    if global.showEditorUi:
      Input.set_default_cursor_shape(Input.CURSOR_ARROW)
    else:
      mouseMode = Input.MOUSE_MODE_CONFINED_HIDDEN

  if event is InputEventMouseMotion and event.screen_relative:
    if state == States.dead \
    and mouseMode != Input.MOUSE_MODE_CONFINED: return
    mouseMode = Input.MOUSE_MODE_CONFINED
    if not camLockPos:
      camLockPos = camera.global_position
    camera.reset_smoothing()
    if Input.is_action_pressed(&"editor_select") and shouldPan:
      global.ui.blockMenu.clearItems()
      camLockPos -= (event.relative.rotated(camera.global_rotation)) * global.useropts.editorScrollSpeed
      var mousePos := get_viewport().get_mouse_position()
      var startPos := mousePos
      if mousePos.x <= 0:
        mousePos.x = global.windowSize.x
      elif mousePos.x >= global.windowSize.x - 1:
        mousePos.x = 0
      if mousePos.y <= 0:
        mousePos.y = global.windowSize.y
      elif mousePos.y >= global.windowSize.y - 1:
        mousePos.y = 0
      if startPos != mousePos:
        isFakeMouseMovement = true
        Input.warp_mouse(mousePos * global.stretchScale)
    # log.pp(camLockPos, "camLockPos")
    updateCamLockPos()

  if mouseMode == Input.mouse_mode: return
  Input.mouse_mode = mouseMode

func _process(delta: float) -> void:
  if global.openMsgBoxCount: return
  updateCamLockPos()
  moveAnimations()

func clearWallData():
  lastWallSide = 0
  lastWallCollisionPoint = null
  lastWall = null
  breakFromWall = false
  wallSlidingFrames = 0
  wallBreakDownFrames = 0

func _physics_process(delta: float) -> void:
  # vel.user.y += 1 * delta
  # sss.y += 1 * delta
  # log.pp(vel.user.y, sss.y, sss.y - vel.user.y)
  # return
  up_direction = global.clearLow(up_direction)
  defaultAngle = up_direction.angle() + deg_to_rad(90)
  if abs(defaultAngle) < .0001:
    defaultAngle = 0
  # log.pp(defaultAngle, up_direction, up_direction.rotated(defaultAngle))
  if state == States.levelLoading:
    respawnCooldown = 0
    return
  if global.ui.modifiers.editorOpen: return
  if global.openMsgBoxCount: return
  respawnCooldown -= delta * 60
  ziplineCooldown -= delta * 60
  if state in [
    States.idle,
    States.moving,
    States.jumping,
    States.wallHang,
    States.falling,
    States.wallSliding,
    States.sliding,
    # States.dead,
    States.bouncing,
    States.inCannon,
    States.pullingLever,
    States.swingingOnPole,
    States.onPulley,
    States.pushing,
    States.onZipline,
    # States.levelLoading,
  ] \
  and not inWaters:
    if Input.is_action_just_pressed(&"jump"):
      ACTIONjump = true
  if !Input.is_action_pressed(&"jump"):
    ACTIONjump = false
  var onStickyFloor = stickyFloorDetector.get_overlapping_areas()
  Engine.time_scale = .3 if global.useropts.slowTime else 1.0
  if global.openMsgBoxCount: return
  if get_viewport().gui_get_focus_owner(): return
  if Input.is_action_pressed(&"editor_select"):
    if root in global.boxSelect_selectedBlocks or root == global.selectedBlock:
      position = Vector2.ZERO
    return
  if state != States.onZipline:
    $ziplineDetector/CollisionShape2D2.shape.size = Vector2(8, 25)
  var frameStartPosition := global_position
  waterRay.rotation = - rotation + defaultAngle
  # anim.position = Vector2(0, 0.145)
  var REAL_GRAV: float = 0
  match gravState:
    GravStates.down:
      REAL_GRAV = GRAVITY * .5 * delta
    GravStates.up:
      REAL_GRAV = GRAVITY * 2 * delta
    GravStates.normal:
      REAL_GRAV = GRAVITY * delta
  match state:
    States.dead:
      # log.pp(up_direction)
      var respawnPosition = tempLastSpawnPoint if tempLastSpawnPoint else lastSpawnPoint
      # log.pp(tempLastSpawnPoint, "tempLastSpawnPoint")
      if not global.showEditorUi:
        camera.global_rotation = defaultAngle
      slowCamRot = false
      deadTimer -= delta * 60
      deadTimer = clampf(deadTimer, 0, currentRespawnDelay)
      # global.tick = global.currentLevel().tick
      if currentRespawnDelay == 0:
        position = respawnPosition
      else:
        position = global.rerange(deadTimer, currentRespawnDelay, 0, deathPosition, respawnPosition)
      camera.position = Vector2.ZERO
      # log.pp(camera.global_position)
      if global.showEditorUi:
        if not camLockPos:
          camLockPos = camera.global_position
      pulleyNoDieTimer = 0
      inWaters = []
      # Engine.time_scale = clampf(global.rerange(deadTimer, currentRespawnDelay, 0, 4, .001), .001, 4)
      anim.animation = "die"
      # setRot(defaultAngle)
      setRot(lerp_angle(rotation, defaultAngle, .2))
      mainCollisionShape2D.rotation = 0
      # hide the water animations
      anim.visible = true
      waterAnimTop.visible = false
      waterAnimBottom.visible = false
      camera.reset_smoothing()
      up_direction = global.currentLevel().up_direction
      if deadTimer <= 0:
        if respawnPosition:
          position = respawnPosition
        else:
          position = Vector2(0, -1.9)
        stopDying()
        global.resendActiveSignals()
      return
    States.inCannon:
      remainingJumpCount = MAX_JUMP_COUNT
      if inWaters:
        state = States.falling
        return
      global_position = activeCannon.thingThatMoves.global_position + (Vector2(0, -130) * activeCannon.scale).rotated(activeCannon.rotation)
      # activeCannon.top_level = true
      if cannonRotationDelayFrames > 0:
        cannonRotationDelayFrames -= delta
      else:
        activeCannon.rotNode.rotation_degrees += delta * WATER_TURNSPEED * getCurrentLrState()
      activeCannon.rotNode.rotation_degrees = clamp(activeCannon.rotNode.rotation_degrees, -25, 25)
      rotation = activeCannon.rotNode.rotation + activeCannon.rotation
      anim.flip_h = rotation < 0
      anim.animation = "idle"
      if ACTIONjump:
        remainingJumpCount -= 1
        vel.cannon = Vector2(0, -17000).rotated(activeCannon.rotation + activeCannon.rotNode.rotation).rotated(-defaultAngle) * activeCannon.scale
        log.pp(vel.cannon)
        justAddedVels.cannon = 5
        vel.user = Vector2.ZERO
        state = States.jumping
        activeCannon.rotNode.rotation_degrees = 0
        activeCannon = null
    States.swingingOnPole:
      if inWaters:
        activePole = null
        state = States.falling
        return
      clearWallData()
      setRot(defaultAngle)
      mainCollisionShape2D.rotation = defaultAngle
      # rotation += 6 * delta
      global_position = activePole.global_position
      anim.animation = "on pole"
      playerKT = 0

      vel.user = Vector2.ZERO

      mainCollisionShape2D.shape.size.y = unduckSize.y / 4
      deathDetectors.scale = Vector2(1, 0.25)

      var xIntent = getCurrentLrState()
      if xIntent > 0:
        anim.flip_h = false
      elif xIntent < 0:
        anim.flip_h = true
      activePole.root.timingIndicator.visible = true
      activePole.root.timingIndicator.global_rotation = 0
      var parentRotation = activePole.global_rotation - activePole.rotation
      if anim.flip_h:
        activePole.root.timingIndicator.rotation = deg_to_rad(135) - parentRotation
        activePole.root.timingIndicator.position = applyRot(Vector2(-55.5, 55.5)).rotated(-parentRotation)
      else:
        activePole.root.timingIndicator.rotation = deg_to_rad(45) - parentRotation
        activePole.root.timingIndicator.position = applyRot(Vector2(55.5, 55.5)).rotated(-parentRotation)
      activePole.root.timingIndicator.rotation += defaultAngle
      remainingJumpCount = MAX_JUMP_COUNT
      if ACTIONjump:
        remainingJumpCount -= 1
        if (anim.frame >= 3 and anim.frame <= 9) or anim.frame >= 27:
          # this one should be user because it makes the falling better
          vel.user.y = JUMP_POWER

          # but this should be pole as that way it does something as user.x is set to xintent
          vel.pole.x = 50 * (-1 if anim.flip_h else 1)
          anim.animation = "jumping off pole"
          anim.animation_looped.connect(func():
            if anim.animation == "jumping off pole":
              anim.animation="jump",
            Object.CONNECT_ONE_SHOT)
          state = States.jumping
        else:
          vel.user.y = 0
          state = States.falling
        activePole.root.timingIndicator.visible = false
        activePole = null
        poleCooldown = MAX_POLE_COOLDOWN
      elif Input.is_action_just_pressed(&"down"):
        remainingJumpCount -= 1
        vel.user.y = 0
        activePole.root.timingIndicator.visible = false
        activePole = null
        state = States.falling
        poleCooldown = MAX_POLE_COOLDOWN
      tryAndDieHazards()
      tryAndDieSquish()
      applyHeat(delta)
      updateKeyFollowPosition(delta)
    States.onPulley:
      clearWallData()
      # setRot(defaultAngle)
      setRot(lerp_angle(rotation, defaultAngle, .2))
      mainCollisionShape2D.rotation = 0

      vel.user = Vector2.ZERO
      remainingJumpCount = MAX_JUMP_COUNT
      global_position = activePulley.thingThatMoves.global_position + Vector2(7, 19)
      # anim.position = Vector2(5, 5.145)
      # anim.position.x *= activePulley.direction
      anim.flip_h = activePulley.direction == -1
      if pulleyNoDieTimer <= 0:
        anim.animation = "on pulley"
        if ACTIONjump:
          pulleyNoDieTimer = MAX_PULLEY_NO_DIE_TIME
          anim.animation = "pulley invins"
      else:
        pulleyNoDieTimer -= delta * 60
        if pulleyNoDieTimer <= 0:
          anim.animation = "on pulley"
          anim.frame = 9

      if pulleyNoDieTimer <= 0:
        tryAndDieHazards()

      if Input.is_action_just_pressed(&"down") or inWaters:
        remainingJumpCount -= 1
        state = States.falling
      applyHeat(delta)
      updateKeyFollowPosition(delta)
    States.onZipline:
      clearWallData()
      setRot(defaultAngle)
      # log.pp(anim.animation, anim.frame)
      anim.animation = &'zipline'
      var heightDiff = abs(targetZipline.global_position.y - activeZipline.global_position.y)
      var lowerZipline = activeZipline if targetZipline.global_position.y < activeZipline.global_position.y else targetZipline
      var higherZipline = targetZipline if lowerZipline == activeZipline else activeZipline
      remainingJumpCount = MAX_JUMP_COUNT
      vel.user.y = 0
      var direction = (lowerZipline.global_position - higherZipline.global_position).normalized()
      if anim.frame > 24:
        if abs(applyRot(velocity).x) < 5:
          anim.frame = 25
        else:
          anim.flip_h = higherZipline.global_position.x > lowerZipline.global_position.x
      else:
        if !is_zero_approx(velocity.x):
          anim.flip_h = applyRot(velocity).x < 0
      var newSpeed = (direction * (heightDiff * .7)) * (clamp(anim.frame, 1, 34) / 34.0) * 6
      # log.pp(vel.zipline, newSpeed, velocity, newSpeed.length(), vel.zipline.length())
      # var diff = Vector2(
      #   abs(newSpeed.normalized()).x - abs(vel.zipline.normalized()).x,
      #   abs(newSpeed.normalized()).y - abs(vel.zipline.normalized()).y
      # )
      # # log.pp(newSpeed.normalized(), vel.zipline.normalized(), diff, abs(newSpeed.normalized()) - abs(vel.zipline.normalized()))
      # if diff:
      #   breakpoint
      # log.pp(newSpeed.length(), vel.zipline.length(), newSpeed, vel.zipline, (newSpeed.normalized()) - (vel.zipline.normalized()))
      # if newSpeed.length() > vel.zipline.length():
      $ziplineDetector/CollisionShape2D2.shape.size = Vector2(8, 25 * global.rerange(abs(newSpeed.x), 0, 300, 1.5, 4))
      if (newSpeed.x > 0) != (vel.zipline.x > 0):
        if newSpeed.x:
          var speed = global.rerange(abs(newSpeed.x), 0, 300, 0.0001, 0.05)
          log.pp(speed, newSpeed.x, vel.zipline.x)
          vel.zipline = lerp(vel.zipline, newSpeed, speed)
      else:
        if abs(newSpeed.x) > abs(vel.zipline.x):
          vel.zipline = newSpeed
      updateKeyFollowPosition(delta)
      if ACTIONjump:
        ACTIONjump = true
        state = States.jumping
        remainingJumpCount -= 1
        ziplineCooldown = MAX_ZIPLINE_COOLDOWN
        _physics_process(delta)
        return
      if Input.is_action_pressed(&"down"):
        remainingJumpCount -= 1
        state = States.falling
        ziplineCooldown = MAX_ZIPLINE_COOLDOWN
        _physics_process(delta)
        return
      # playerXIntent = MOVESPEED * getCurrentLrState() * \
      #   (2 if speedLeverActive else 1)
      # vel.user = Vector2(playerXIntent, 0)
      var uservel = direction.normalized().abs() * vel.user.length() * (-1 if vel.user.x < 0 else 1)
      velocity = Vector2.ZERO
      vel.user *= .95
      # if anim.frame >= 34:
      # for n: String in vel:
      #   if n == 'user' and playerKT > 0:
      #     velocity += applyRot(Vector2(vel[n].x, 0))
      #   else:
      #     velocity += applyRot(vel[n])
      velocity += applyRot(vel.zipline)
      velocity += applyRot(uservel)
      # for n: String in vel:
      #   if n != 'zipline':
      #     vel[n] *= (velDecay[n]) # * delta * 60
      # if Input.is_key_pressed(KEY_T):
      #   breakpoint
      for n: String in vel:
        if justAddedVels[n]:
          justAddedVels[n] -= 1
      move_and_slide()
      tryAndDieHazards()
    States.bouncing:
      setRot(defaultAngle)
      mainCollisionShape2D.rotation = 0
      clearWallData()
      slideRecovery = 0
      duckRecovery = 0
      wallBreakDownFrames = 0
      anim.animation = "duck start"
      vel.user.y = 0
      updateKeyFollowPosition(delta)
      return
    States.pullingLever:
      setRot(defaultAngle)
      mainCollisionShape2D.rotation = 0
      anim.animation = "pulling lever"
      anim.animation_looped.connect(func() -> void:
        if state == States.dead: return
        state=States.idle, Object.CONNECT_ONE_SHOT)
      tryAndDieHazards()
      tryAndDieSquish()
      applyHeat(delta)
      updateKeyFollowPosition(delta)
    _:
      if inWaters:
        floor_snap_length = 0
        # show the water animations
        mainCollisionShape2D.rotation = 0
        waterAnimTop.visible = true
        waterAnimBottom.visible = true
        anim.visible = false
        # turn player
        rotation_degrees += delta * WATER_TURNSPEED * Input.get_axis("left", "right")
        # dont store velocity from normal movement if in water
        vel.user = Vector2.ZERO
        # set state to falling for when player exits the water
        state = States.falling
        # move forward or backward based on input
        if levelFlags.autoRun:
          velocity += Vector2(-transform.y) * delta * WATER_MOVESPEED * 1
        else:
          velocity += Vector2(-transform.y) * delta * WATER_MOVESPEED * Input.get_axis("down", "jump")
        velocity *= .8
        # only bounce out of the water if going up
        for v: String in vel:
          vel[v] = Vector2.ZERO
        if waterRay.is_colliding() and Input.is_action_pressed(&"jump"):
          vel.waterExit = Vector2(Vector2(0, WATER_EXIT_BOUNCE_FORCE).rotated(rotation - defaultAngle))
        # reset some variables to allow player to grab both walls when exiting water
        playerXIntent = 0
        clearWallData()
        slideRecovery = 0
        duckRecovery = 0
        # can be used to prevent pressing jump quickly again after exiting water to get ~2x height
        if playerKT > 0:
          playerKT = MAX_WATER_KT_TIMER
        for i in get_slide_collision_count():
          var collision := get_slide_collision(i)
          var block := collision.get_collider()
          var normal := collision.get_normal()
          var depth := collision.get_depth()
          handleCollision(block, normal, depth, collision.get_position())
        wasJustInWater = true
        move_and_slide()
        tryAndDieHazards()
      else:
        if vel.pole:
          vel.pole.x -= 2 * sign(vel.pole.x) * delta * 60
        if vel.user.y < -SMALL:
          floor_snap_length = 2
        else:
          floor_snap_length = 6
          if speedLeverActive:
            floor_snap_length = 9
        # log.pp(remainingJumpCount, "remainingJumpCount", States.keys()[state])
        # reset angle when exiting water
        # setRot(defaultAngle)
        setRot(lerp_angle(rotation, defaultAngle, .2))
        mainCollisionShape2D.rotation = 0
        # if state == States.wallHang:
        #   if (CenterIsOnWall() and !TopIsOnWall()):
        #     state = States.falling
        # hide the water animations
        anim.visible = true
        waterAnimTop.visible = false
        waterAnimBottom.visible = false

        # lower all frame counters
        if wallSlidingFrames > 0:
          wallSlidingFrames -= delta * 60
        if slideRecovery > 0:
          slideRecovery -= delta * 60
        if wallBreakDownFrames > 0:
          wallBreakDownFrames -= delta * 60
        if duckRecovery > 0:
          duckRecovery -= delta * 60
        if playerKT > 0:
          playerKT -= delta * 60
          if playerKT <= 0:
            remainingJumpCount -= 1
        if poleCooldown > 0:
          poleCooldown -= delta * 60
        if boxKickRecovery > 0:
          boxKickRecovery -= delta * 60
          if boxKickRecovery <= 0:
            position += Vector2(0, 2).rotated(defaultAngle)
          return

        if state == States.wallHang || state == States.wallSliding:
          # remainingJumpCount = MAX_JUMP_COUNT
          if not is_on_wall() and getClosestWallSide():
            var ray: RayCast2D = getClosestWallRay()
            var origin: Vector2 = ray.global_transform.origin
            var collision_point := ray.get_collision_point()
            var distance := origin.distance_to(collision_point)
            # log.pp(distance * getClosestWallSide())
            position += Vector2((distance) * getClosestWallSide(), 0).rotated(defaultAngle)
            # position += Vector2((distance) * getClosestWallSide(), 0).rotated(defaultAngle) * 2
        # if on floor reset kt, user y velocity, and allow both wall sides again
        if is_on_floor():
          if !onStickyFloor:
            playerKT = MAX_KT_TIMER
            remainingJumpCount = MAX_JUMP_COUNT
          vel.user.y = 0
          lastWallSide = 0
          lastWallCollisionPoint = null
          breakFromWall = false
          # if not moving or trying to not move, go idle
          if !vel.user || !playerXIntent || playerXIntent != vel.user.x:
            if state == States.sliding && !Input.is_action_pressed(&"down"):
              if abs(vel.user.x) < 10:
                duckRecovery = MAX_SLIDE_RECOVER_TIME
              else:
                slideRecovery = MAX_SLIDE_RECOVER_TIME
            state = States.idle
          # log.pp(vel.user, playerXIntent, playerXIntent != vel.user.x, state, States.idle, floor_max_angle)
        else:
          # if not on floor and switching wall sides allow both walls again
          if (
            levelFlags.canDoWallSlide &&
            (lastWallSide && (getCurrentWallSide() && lastWallSide != getCurrentWallSide()))
            or onDifferentWall()
          ) and not collidingWithNowj():
            lastWallSide = 0
            lastWallCollisionPoint = null
            lastWall = null
            breakFromWall = false
            # remainingJumpCount = MAX_JUMP_COUNT
            state = States.wallSliding
          if state != States.wallHang:
            currentHungWall = 0
          # should enter wall grab state if not already in wall hang state and moving down
          # log.pp(velocity.y)
          if vel.user.y > -20 && state != States.wallHang:
            # log.pp("entering wall grab", CenterIsOnWall(), TopIsOnWall())
            if levelFlags.canDoWallHang && (CenterIsOnWall() && !TopIsOnWall() and not collidingWithNowj()):
              currentHungWall = rightWallDetection.get_collider() if getCurrentWallSide() == 1 else leftWallDetection.get_collider()
              hungWallSide = getCurrentWallSide()
              state = States.wallHang
              var loopIdx: int = 0
              while !TopIsOnWall() and loopIdx < 20:
                loopIdx += 1
                position += Vector2(0, 1).rotated(defaultAngle)
                leftWallTopDetection.force_raycast_update()
                rightWallTopDetection.force_raycast_update()
              if loopIdx >= 20:
                position -= Vector2(0, loopIdx).rotated(defaultAngle)
                log.pp("fell off wall hang")
                # remainingJumpCount -= 1
                state = States.falling
              position -= Vector2(0, 5).rotated(defaultAngle)
              breakFromWall = true
              lastWallSide = 0
              lastWallCollisionPoint = null
              lastWall = null
            # if levelFlags.canDoWallHang && ((
            #   is_on_wall() and (
            #     (
            #       leftWallDetection.is_colliding() and not leftWallTopDetection.is_colliding()
            #     ) or (
            #       rightWallDetection.is_colliding() and not rightWallTopDetection.is_colliding()
            #     )
            #   )
            # ) and not collidingWithNowj()):
            #   currentHungWall = rightWallDetection.get_collider() if getCurrentWallSide() == 1 else leftWallDetection.get_collider()
            #   hungWallSide = getCurrentWallSide()
            #   state = States.wallHang
            #   var loopIdx: int = 0
            #   var ray = rightWallTopDetection if getCurrentWallSide() == 1 else leftWallTopDetection
            #   log.pp(ray, getCurrentWallSide())
            #   while !ray.is_colliding() and loopIdx < 20:
            #     loopIdx += 1
            #     position += Vector2(0, 1).rotated(defaultAngle)
            #     ray.force_raycast_update()
            #     # rightWallTopDetection.force_raycast_update()
            #   if loopIdx >= 20:
            #     position -= Vector2(0, loopIdx).rotated(defaultAngle)
            #     log.pp("fell off wall hang")
            #     # remainingJumpCount -= 1
            #     state = States.falling
            #   position -= Vector2(0, 5).rotated(defaultAngle)
            #   breakFromWall = true
            #   lastWallSide = 0
            #   lastWallCollisionPoint = null
            #   lastWall = null

          # if not in wall hang state and near a wall
          if state != States.wallHang && getCurrentWallSide() and not collidingWithNowj():
            lastWallSide = getCurrentWallSide()
            lastWallCollisionPoint = getClosestWallRay().get_collision_point()
            lastWall = getCurrentWall()

          if state == States.wallSliding and collidingWithNowj():
            state = States.falling
          if (
            levelFlags.canDoWallSlide and (
              CenterIsOnWall() && not is_on_floor() && !breakFromWall \
              && vel.user.y > 0 && wallBreakDownFrames <= 0 \
              and not collidingWithNowj()
            )
          ):
            vel.user.y = WALL_SLIDE_SPEED

            # remainingJumpCount = MAX_JUMP_COUNT
            state = States.wallSliding
            # press down to detach from wallslide
            if Input.is_action_pressed(&"down") && wallBreakDownFrames <= 0:
              breakFromWall = true
            if !breakFromWall && wallSlidingFrames <= 0:
              wallSlidingFrames = MAX_WALL_SLIDE_FRAMES
            if wallSlidingFrames <= 1:
              wallSlidingFrames -= 1
              breakFromWall = true
          else:
            # log.pp(vel.user, REAL_GRAV)
            vel.user.y += REAL_GRAV

            # log.pp(vel.user, REAL_GRAV)

        if breakFromWall:
          wallSlidingFrames = 0
        # jump from walljump
        if (
          levelFlags.canDoWallJump
          and state == States.wallSliding
          and !breakFromWall
          and not onStickyFloor
          and ACTIONjump
        ):
          # remainingJumpCount -= 1
          autoRunDirection *= -1
          state = States.jumping
          breakFromWall = true

          vel.user.y = JUMP_POWER

        if (state == States.wallHang) && is_on_wall_only() && CenterIsOnWall():
          remainingJumpCount = MAX_JUMP_COUNT
          vel.user.y = 0

          wallSlidingFrames = 0
          breakFromWall = false
          # press down to detach from wallhang
          if Input.is_action_pressed(&"down"):
            position += Vector2(0, 6).rotated(defaultAngle)
            wallBreakDownFrames = MAX_WALL_BREAK_FROM_DOWN_FRAMES
            remainingJumpCount -= 1
            state = States.falling

        # jump from wall grab or from the ground
        if !Input.is_action_pressed(&"down"):
          if (remainingJumpCount > 0) || state == States.wallHang:
            if not onStickyFloor:
              if duckRecovery <= 0 and ACTIONjump:
                remainingJumpCount -= 1
                state = States.jumping
                playerKT = 0
                vel.user.y = JUMP_POWER

        # if not in duckRecovery or wall hang or wallSliding, allow movement
        if (!breakFromWall and (state == States.wallSliding || state == States.wallHang)) \
          or duckRecovery > 0:
          playerXIntent = 0
        else:
          playerXIntent = MOVESPEED * getCurrentLrState() * \
          (2 if speedLeverActive else 1)

        # enter slide mode when pressing down key and on the ground
        if is_on_floor() && Input.is_action_pressed(&"down"):
          state = States.sliding

        # check for falling
        if !is_on_floor() \
        && !is_on_wall() \
        && !getClosestWallRay():
          if vel.user.y < 0:
            state = States.jumping
          else:
            # for when getting pushed off a wall
            if state == States.wallHang:
              remainingJumpCount -= 1
            state = States.falling

        # # # do a short hop if pressing down after jumping
        # if Input.is_action_pressed(&"down"):
        #   for v in vel:
        #     if vel[v].y < 0:
        #       var c = delta * 1000
        #       log.pp(c)
        #       vel[v].y += c

        # shrink hitbox when ducking or sliding
        if state == States.sliding:
          mainCollisionShape2D.shape.size.y = unduckSize.y / 2
          mainCollisionShape2D.position.y = unduckPos.y + (unduckSize.y / 4)
          deathDetectors.scale = Vector2(1, 0.5)
          deathDetectors.position.y = (unduckSize.y / 4)
        else:
          mainCollisionShape2D.shape.size.y = unduckSize.y
          mainCollisionShape2D.position.y = unduckPos.y
          deathDetectors.scale = Vector2(1, 1)
          deathDetectors.position.y = 0
        if state == States.wallHang && (CenterIsOnWall() && TopIsOnWall() and not collidingWithNowj()):
          # currentHungWall = getCurrentWall()
          hungWallSide = getCurrentWallSide()
          var loopIdx: int = 0
          while TopIsOnWall() and loopIdx < 20:
            loopIdx += 1
            # log.pp(loopIdx)
            position -= Vector2(0, 1).rotated(defaultAngle)
            leftWallTopDetection.force_raycast_update()
            rightWallTopDetection.force_raycast_update()
          if loopIdx >= 20:
            position += Vector2(0, loopIdx).rotated(defaultAngle)
            log.pp("fell off wall hang to wallSliding")
            remainingJumpCount -= 1
            state = States.wallSliding
          else:
            position -= Vector2(0, 1).rotated(defaultAngle)

        # if state == States.wallHang && ((
        #   is_on_wall() and (
        #     (
        #       getCurrentWallSide() == -1 and leftWallDetection.is_colliding() and leftWallTopDetection.is_colliding()
        #     ) or (
        #       getCurrentWallSide() == 1 and rightWallDetection.is_colliding() and rightWallTopDetection.is_colliding()
        #     )
        #   )
        # ) and not collidingWithNowj()):
        #   # currentHungWall = getCurrentWall()
        #   hungWallSide = getCurrentWallSide()
        #   var loopIdx: int = 0
        #   currentHungWall = rightWallDetection.get_collider() if getCurrentWallSide() == 1 else leftWallDetection.get_collider()
        #   var ray = rightWallTopDetection if 1 == 1 else leftWallTopDetection
        #   log.pp(ray, getCurrentWallSide(), 222)

        #   while ray.is_colliding() and loopIdx < 20:
        #     loopIdx += 1
        #     # log.pp(loopIdx)
        #     position -= Vector2(0, 1).rotated(defaultAngle)
        #     ray.force_raycast_update()
        #   if loopIdx >= 20:
        #     position += Vector2(0, loopIdx).rotated(defaultAngle)
        #     log.pp("fell off wall hang to wallSliding")
        #     remainingJumpCount -= 1
        #     state = States.wallSliding
        #   else:
        #     position -= Vector2(0, 1).rotated(defaultAngle)

        # animations
        if anim.animation == "jumping off pole" and vel.user.y != 0: pass
        else:
          if duckRecovery > 0:
            anim.animation = "duck end"
          elif slideRecovery > 0:
            anim.animation = "slide end"
          else:
            match state:
              States.idle:
                anim.animation = "idle"
              States.moving:
                anim.animation = "run"
              States.jumping:
                anim.animation = "jump"
              States.falling:
                anim.animation = "jump"
              States.wallSliding:
                if breakFromWall:
                  anim.animation = "jump"
                else:
                  anim.animation = "wall slide"
              States.sliding:
                if abs(vel.user.x) < 10:
                  anim.animation = "duck start"
                else:
                  anim.animation = "slide start"
              States.wallHang:
                anim.animation = "wall hang"
              States.pushing:
                anim.animation = "pushing box"
              _:
                anim.animation = "idle"

        # set the sprite direction based on playerXIntent

        # when trying to slide and not moving enough, duck instead
        if state == States.sliding:
          # if sliding reduce speed reuction
          if abs(vel.user.x) < 10:
            vel.user.x = 0
          vel.user.x *= 0.98 # * delta * 60
        # if state is not sliding
        else:
          if playerXIntent > 0:
            anim.flip_h = false
          elif playerXIntent < 0:
            anim.flip_h = true
          # if user not trying to move set user xvel to 0
          if playerXIntent == 0:
            vel.user.x = 0
          else:
            # if user trying to move and on floor set state to moving
            if is_on_floor():
              state = States.moving
            vel.user.x = playerXIntent
          # reduce speed after leaving slide, with the power reducing over time
          vel.user.x *= 1 - slideRecovery / MAX_SLIDE_RECOVER_TIME
          # if you were ducking instead of sliding, stop all movement
          if duckRecovery > 0:
            vel.user.x = 0

        # stopVelOnGround
        if is_on_floor():
          wasJustInWater = false
          for n: String in stopVelOnGround:
            if !justAddedVels[n]:
              vel[n] = Vector2.ZERO
        # stopVelOnWall
        if state == States.wallHang or state == States.wallSliding:
          for n: String in stopVelOnWall:
            if !justAddedVels[n]:
              vel[n] = Vector2.ZERO
        # stopVelOnCeil
        if is_on_ceiling():
          if vel.user.y < 0:
            vel.user.y = 0
          for n: String in stopVelOnCeil:
            if !justAddedVels[n]:
              vel[n] = Vector2.ZERO
        vel.conveyer = global.clearLow(vel.conveyer)
        # if vel.conveyer:
        #   log.pp(vel.conveyer)
        # move using all velocities
        velocity = Vector2.ZERO
        if state != States.wallHang:
          for n: String in vel:
            if n == 'user' and playerKT > 0:
              velocity += applyRot(Vector2(vel[n].x, 0))
            else:
              velocity += applyRot(vel[n])
          for n: String in vel:
            vel[n] *= (velDecay[n]) # * delta * 60
        # if Input.is_key_pressed(KEY_T):
        #   breakpoint
        if state == States.wallHang and not getClosestWallSide():
          remainingJumpCount -= 1
          state = States.falling
        for n: String in vel:
          if justAddedVels[n]:
            justAddedVels[n] -= 1
        move_and_slide()
        # var floorRayCollision: Node2D = null
        for i in get_slide_collision_count():
          var collision := get_slide_collision(i)
          var block := collision.get_collider()

          var normal := collision.get_normal()
          var depth := collision.get_depth()
          # log.pp(block.id if 'id' in block else block.root.id, normal, depth, block == floorRayCollision)
          # collision.get_position()

          # if block == floorRayCollision:
          #   floorRayCollision = null
          handleCollision(block, normal, depth, collision.get_position())

        # if floorRayCollision:
        #   handleCollision(floorRayCollision, Vector2(0, -1), 1)
        # trying to fix some downward collisions not having correct normal
        if state != States.wallHang:
          position += applyRot(Vector2(0, safe_margin))
        tryAndDieHazards()
        tryAndDieSquish()
      # log.pp(heat, "Heat")
      applyHeat(delta)
      updateKeyFollowPosition(delta)
  if !global.showEditorUi:
    var changeInPosition: Vector2 = global_position - frameStartPosition
    var maxVel: float = max(abs(changeInPosition.x), abs(changeInPosition.y)) * delta * 60
    if maxVel > 50:
      camera.position_smoothing_enabled = false
    else:
      camera.position_smoothing_enabled = true
      camera.position_smoothing_speed = clamp(maxVel, 5, 10)
    # var smoothingFactor: float = global.rerange(maxVel, 0, 400, 5, 19)

    # smoothingFactor = clamp(smoothingFactor, 5, 19)

    # var startPos = camera.position
    # camera.position = changeInPosition
    # if maxVel > 5:
    #   camera.position -= (camera.position - changeInPosition) * 15 * delta
    # Vector2(
    #   pow(changeInPosition.x,1) * 3.7,
    #   pow(changeInPosition.y,1) * 3.7
    # )
    # # camera.position -= camera.position * delta * 20
    # if (camera.position.x > 0) != (startPos.x > 0):
    #   camera.position.x = 0
    # if (camera.position.y > 0) != (startPos.y > 0):
    #   camera.position.y = 0
    # camera.position_smoothing_speed = smoothingFactor
    # camera.position -= camera.position * .5 * delta
  var camrot = camera.global_rotation
  if camrot < 0:
    camrot += deg_to_rad(360)
    # log.pp(camera.global_rotation, " ---- ", defaultAngle, rad_to_deg(defaultAngle), rad_to_deg(camera.global_rotation), camrot)
    # log.pp(abs(camera.rotation),abs(camera.rotation) < .3)
  var targetAngle = camRotLock if global.showEditorUi else defaultAngle
  # log.pp(camRotLock, "camRotLock", targetAngle, camrot, camera.global_rotation)
  if global.useropts.dontChangeCameraRotationOnGravityChange:
    camera.global_rotation = 0
  else:
    if global.showEditorUi:
      if global.useropts.cameraUsesDefaultRotationInEditor:
        camera.global_rotation = 0
      else:
        camera.global_rotation = targetAngle
    else:
      if angle_distance(rotation, targetAngle) < SMALL:
        slowCamRot = false
      if not slowCamRot \
       or inWaters \
       or global.useropts.cameraRotationOnGravityChangeHappensInstantly:
        camera.global_rotation = targetAngle
      else:
        camera.global_rotation = lerp_angle(camrot, targetAngle, .15)
  # log.pp(slowCamRot, angle_distance(rotation, targetAngle), rotation, targetAngle)
    # camera.global_rotation = deg_to_rad(0)
  # else:
  #   camera.global_rotation = deg_to_rad(0)
    # log.pp(camera.position, changeInPosition)

    # log.pp(camera.position_smoothing_speed, maxVel)

func moveAnimations():
  var flip_h = -1 if anim.flip_h else 1
  var temp = (func():
    match anim.animation:
      &'die':
        return [Vector2(4.0, 0.145), Vector2.ZERO]
      &'wall hang':
        return [Vector2(0.0, 0.145), Vector2.ZERO]
      &'jump':
        return [Vector2(2.0, 0.145), Vector2.ZERO]
      &'idle':
        return [Vector2(0.0, 0.145), Vector2.ZERO]
      &'zipline':
        return [Vector2(0.0, 10.145), Vector2.ZERO]
      &'wall slide':
        return [Vector2(0.0, 0.145), Vector2.ZERO]
      &'run':
        return [Vector2(3.0, 0.145), Vector2.ZERO]
      &'duck start':
        return [Vector2(2.5, 0.145), Vector2.ZERO]
      &'duck end':
        return [Vector2(2.5, 0.145), Vector2.ZERO]
      &'slide end':
        return [Vector2(-3, 0.145), Vector2.ZERO]
      &'slide start':
        return [Vector2(-3, 0.145), Vector2.ZERO]
      &'pulling lever':
        return [Vector2(3.7, 0.2), Vector2.ZERO]
      &'pushing box':
        return [Vector2(0, 0.145), Vector2.ZERO]
      &'on pulley':
        return [Vector2(2.5, 3.145), Vector2(-5.5, 3.0)]
      &'pulley invins':
        return [Vector2(2.5, 3.145), Vector2(-5.5, 3.0)]
      &'on pole':
        return [Vector2(0, 1.145), Vector2.ZERO]
      &'jumping off pole':
        return [Vector2(0, 1.145), Vector2.ZERO]
      &'kicking box':
        return [Vector2(0, 1.145), Vector2.ZERO]
      _:
        log.err(anim.animation, "has no set position")
        return [Vector2(10.0, 10.145), Vector2.ZERO]
  ).call()
  temp[0].x *= flip_h
  temp[1].x *= flip_h
  anim.position = temp[0]
  # anim.position = lerp(anim.position, temp[0], .6)
  for collider in [
    nowjDetector,
    mainCollisionShape2D,
    stickyFloorDetector,
    respawnDetectionArea,
    waterRay,
    wallDetectors,
    deathDetectors
  ]:
    collider.position = temp[1]
  if state == States.sliding:
    mainCollisionShape2D.shape.size.y = unduckSize.y / 2
    mainCollisionShape2D.position.y = unduckPos.y + (unduckSize.y / 4)
    deathDetectors.scale = Vector2(1, 0.5)
    deathDetectors.position.y = (unduckSize.y / 4)

func onDifferentWall() -> bool:
  if not lastWall:
    return false
  if getCurrentWall() && lastWall != getCurrentWall():
    if not lastWallCollisionPoint:
      return true
    return !is_equal_approx(getClosestWallRay().get_collision_point().x, lastWallCollisionPoint.x)
  return false

func getClosestWallRay() -> RayCast2D:
  if rightWallDetection.is_colliding() and leftWallDetection.is_colliding():
    if anim.flip_h: return leftWallDetection
    else: return rightWallDetection
  if rightWallDetection.is_colliding(): return rightWallDetection
  if leftWallDetection.is_colliding(): return leftWallDetection
  return null

func getCurrentLrState():
  if levelFlags.autoRun:
    return autoRunDirection
  return Input.get_axis("left", "right")

func applyHeat(delta):
  var heatToAdd = 0
  for laser in targetingLasers:
    if laser.hitPlayer:
      # base of 1
      var num = 1 \
      # a little bit more based on distance when less than 100 px
      + max(0, ((100 - laser.thingThatMoves.global_position.distance_to(global_position)) / 50.0)) \
      # a lot more based on distance when very close less than 20 px
      + max(0, ((20 - laser.thingThatMoves.global_position.distance_to(global_position)) / 3.0))
      heatToAdd += num
      # log.pp('heatToAdd num', num)
  heat += heatToAdd * delta
  if heat > 0:
    heat -= (.75 if inWaters else .5) * delta
  heat = clamp(heat, 0, 1)
  if heat == 1:
    die()
  # modulate.r = heat
  for thing in [anim, waterAnimTop, waterAnimBottom]:
    thing.material.set_shader_parameter("replace", Color(heat, 0, 0, 1))
func collidingWithNowj():
  var wallSIde = getCurrentWallSide()
  var bodies = nowjDetector.get_overlapping_bodies()
  var collision = false
  # log.pp(wallSIde)
  # log.pp(bodies)
  for body in bodies:
    var block: EditorBlock = body.root
    var angdiff = angle_difference(deg_to_rad(block.startRotation_degrees), defaultAngle)
    var v = Vector2(1, 0).rotated(angdiff)
    # log.pp(v.x, wallSIde, block.startRotation_degrees, defaultAngle, angdiff)
    if abs(v.x - wallSIde) < .01:
      collision = true
      break

  return collision
func angle_distance(angle1: float, angle2: float) -> float:
  var difference = angle2 - angle1
  difference = fposmod(difference + PI, TAU) - PI
  return abs(difference)

func tryAndDieHazards():
  if len(deathSources.filter(func(e):
    return global.isAlive(e) and !e.respawning)):
    die()
func tryAndDieSquish():
  if (len(collsiionOn_top) and len(collsiionOn_bottom)) \
  or (len(collsiionOn_left) and len(collsiionOn_right)):
    # log.pp(collsiionOn_top, collsiionOn_bottom, collsiionOn_left, collsiionOn_right)
    die(DEATH_TIME, false, false)

func calcHitDir(normal):
  var hitTop = normal.distance_to(up_direction) < 0.77
  var hitBottom = normal.distance_to(up_direction.rotated(deg_to_rad(180))) < 0.77
  var hitLeft = normal.distance_to(up_direction.rotated(deg_to_rad(-90))) < 0.77
  var hitRight = normal.distance_to(up_direction.rotated(deg_to_rad(90))) < 0.77
  var single = len([hitTop, hitBottom, hitLeft, hitRight].filter(func(e): return e)) == 1

  return {"top": hitTop, "bottom": hitBottom, "left": hitLeft, "right": hitRight, "single": single}

func handleCollision(b: Node2D, normal: Vector2, depth: float, position: Vector2) -> void:
  var block: EditorBlock = b.root
  var blockSide = calcHitDir(normal.rotated(defaultAngle).rotated(-deg_to_rad(block.startRotation_degrees)))

  var v = normal.rotated(-defaultAngle)
  var vv = Vector2.UP
  var hitTop = v.distance_to(vv) < 0.77
  var hitBottom = v.distance_to(vv.rotated(deg_to_rad(180))) < 0.77
  var hitLeft = v.distance_to(vv.rotated(deg_to_rad(-90))) < 0.77
  var hitRight = v.distance_to(vv.rotated(deg_to_rad(90))) < 0.77
  var single = len([hitTop, hitBottom, hitLeft, hitRight].filter(func(e): return e)) == 1
  var playerSide = {"top": hitBottom, "bottom": hitTop, "left": hitRight, "right": hitLeft, "single": single}
  if block.respawning: return
  if (
    block is BlockDonup
    or block is BlockFalling
  ):
    log.pp(applyRot(velocity), velocity)
  if (
    block is BlockDonup
    or block is BlockFalling
  ) \
  and playerSide.bottom \
  and applyRot(velocity).y >= -SMALL \
  :
    block.falling = true
  if block is BlockGlass \
  and playerSide.bottom \
  and applyRot(velocity).y >= -SMALL \
  and vel.user.y > SMALL \
  and Input.is_action_pressed(&"down") \
  :
    block.__disable()
  if block is BlockBouncy \
  and blockSide.top \
  and applyRot(velocity).y >= -SMALL \
  and not inWaters \
  and not block.respawnTimer > 0 \
  :
    # breakpoint
    # global_position = position
    # breakpoint
    global_position = position - Vector2(4, 0)
    # breakpoint
    # log.err(normal * depth)
    block.start()
  if block is BlockInnerLevel \
  and playerSide.bottom \
  and state == States.sliding \
  and abs(vel.user.x) < 10 \
  :
    block.enterLevel()
  if block is BlockLockedBox \
  or block is Block10xLockedSpike \
  :
    block.unlock()
  if (block is BlockPushableBox or block is BlockBomb) \
  and getClosestWallSide() \
  and Input.is_action_just_pressed(&"down") \
  and not inWaters \
  and playerSide.bottom \
  :
    anim.flip_h = getClosestWallSide() == 1
    block.thingThatMoves.vel.default -= Vector2(getClosestWallSide() * 140, 0)
    anim.animation = "kicking box"
    boxKickRecovery = MAX_BOX_KICK_RECOVER_TIME
    position -= Vector2(0, 2).rotated(defaultAngle)

  if (block is BlockCrumbling):
    block.start()
  if (block is BlockPushableBox or block is BlockBomb) \
  and is_on_floor() \
  and (playerSide.left or playerSide.right) \
  and not inWaters \
  :
    block.thingThatMoves.vel.default -= (normal.rotated(-defaultAngle) * depth * 200)
    state = States.pushing
    anim.animation = "pushing box"
  # if block is BlockConveyer:
  #   if rotatedNormal != UP:
    # log.err([rotatedNormal, UP], defaultAngle, up_direction, [normal, Vector2.UP])

  if (block is BlockConveyer) \
  # and playerSide.bottom \
  and not inWaters \
  and vel.user.y >= -SMALL \
  :
    var speed = 400
    # log.pp(normal == Vector2(-1, 0), blockSide)
    # log.pp(vel.conveyer)
    if not blockSide.single: return
    if playerSide.bottom and blockSide.top:
      vel.conveyer.x = - speed
    elif playerSide.bottom and blockSide.bottom:
      vel.conveyer.x = speed
    elif playerSide.bottom and blockSide.left: return
    elif playerSide.bottom and blockSide.right: return
    elif playerSide.left and blockSide.left: return
    elif playerSide.right and blockSide.right: return
    elif playerSide.right and blockSide.left: return
    elif playerSide.left and blockSide.right: return
    elif playerSide.left and blockSide.top:
      vel.conveyer.y = - speed
      wallSlidingFrames = 0
    elif playerSide.left and blockSide.bottom:
      vel.conveyer.y = speed
    elif playerSide.right and blockSide.top:
      vel.conveyer.y = speed
    elif playerSide.right and blockSide.bottom:
      vel.conveyer.y = - speed
      wallSlidingFrames = 0
    elif playerSide.top and blockSide.top: return
    elif playerSide.top and blockSide.bottom: return
    else:
      log.err("invalid collision direction!!!", normal, playerSide, blockSide)
    justAddedVels.conveyer = 3

func updateCamLockPos():
  if global.showEditorUi:
    camera.global_position = camLockPos
    camera.reset_smoothing()

func goto(pos: Vector2) -> void:
  position = pos
  vel.user = Vector2.ZERO
  camera.position = Vector2.ZERO
  camera.reset_smoothing()

func TopIsOnWall() -> bool:
  return is_on_wall() && (leftWallTopDetection.is_colliding() || rightWallTopDetection.is_colliding())
func CenterIsOnWall() -> bool:
  return is_on_wall() && (leftWallDetection.is_colliding() || rightWallDetection.is_colliding())

func getClosestWall() -> EditorBlock:
  return getClosestWallRay().get_collider().root if getClosestWallRay() else null

func getCurrentWall() -> EditorBlock:
  if !is_on_wall(): return null
  return getClosestWall()
func getCurrentWallSide() -> int:
  if !is_on_wall(): return 0
  return getClosestWallSide()
func getClosestWallSide() -> int:
  var temp = getClosestWallRay()
  if temp == rightWallDetection:
    return 1
  if temp == leftWallDetection:
    return -1
  return 0

func setRot(rot):
  var startRot = camera.global_rotation
  rotation = rot
  if camRotLock and global.showEditorUi:
    camera.global_rotation = camRotLock
  else:
    camera.global_rotation = startRot

signal OnPlayerDied
signal OnPlayerFullRestart
signal Alltryaddgroups

func stopDying():
  if state == States.dead:
    tempLastSpawnPoint = Vector2.ZERO
    state = States.falling
    await global.wait()
    root.__enable.call_deferred()
    global.stopTicking = false

func die(respawnTime: int = DEATH_TIME, full:=false, forced:=false) -> void:
  if respawnCooldown >= 0 and not forced:
    deathSources = []
    return

  updateCollidingBlocksExited()

  if state != States.levelLoading:
    state = States.dead
  root.__disable()
  respawnCooldown = respawnTime + .01
  # log.pp("Player died", respawnTime, full, "lastSpawnPoint", lastSpawnPoint)
  lastDeathWasForced = forced
  # root.__disable()
  # process_mode = Node.PROCESS_MODE_DISABLED
  var dontResetPlayerData := false
  if not forced and state != States.levelLoading and not full:
    dontResetPlayerData = !!tryChangeRespawnLocation()
  if full:
    lastSpawnPoint = Vector2.ZERO
    global.tick = 0
    global.currentLevel().tick = 0
    global.currentLevel().up_direction = Vector2.UP
    global.currentLevel().autoRunDirection = 1
    global.currentLevel().heat = 0
    global.currentLevel().gravState = GravStates.normal
    global.currentLevel().speedLeverActive = false
    autoRunDirection = 1
  else:
    global.tick = global.currentLevel().tick
    up_direction = global.currentLevel().up_direction
    autoRunDirection = global.currentLevel().autoRunDirection
    if global.currentLevelSettings("checkpointsSaveAll"):
      heat = global.currentLevel().heat
  mainCollisionShape2D.disabled = true
  slowCamRot = false
  targetingLasers = []
  activeCannon = null
  activePulley = null
  activeZipline = null
  targetZipline = null
  global.stopTicking = true
  deadTimer = max(respawnTime, 0)
  currentRespawnDelay = respawnTime
  deathPosition = position
  playerXIntent = 0
  lastWallCollisionPoint = null
  lastWallSide = 0
  lastWall = null
  pulleyNoDieTimer = 0
  breakFromWall = false
  wallSlidingFrames = 0
  slideRecovery = 0
  duckRecovery = 0
  wallBreakDownFrames = 0
  inWaters = []
  collsiionOn_top = []
  collsiionOn_bottom = []
  collsiionOn_left = []
  collsiionOn_right = []
  deathSources = []
  global.lastPortal = null
  if !dontResetPlayerData:
    if global.currentLevelSettings("checkpointsSaveAll"):
      gravState = global.currentLevel().gravState
      speedLeverActive = global.currentLevel().speedLeverActive
    else:
      gravState = GravStates.normal
      speedLeverActive = false
    keys = []
    for v: String in vel:
      vel[v] = Vector2.ZERO
    velocity = Vector2.ZERO
    lightsOut = false
    if full:
      OnPlayerFullRestart.emit()
      global.savePlayerLevelData()
    else:
      OnPlayerDied.emit()
      if global.currentLevelSettings("checkpointsSaveAll"):
        global.loadBlockData()
  await global.wait()
  Alltryaddgroups.emit.call_deferred()
  _physics_process(0)

func tryChangeRespawnLocation():
  var deathRay := RayCast2D.new()
  deathRay.collide_with_areas = true
  deathRay.collide_with_bodies = false
  deathRay.target_position = lastSpawnPoint - position
  deathRay.collision_mask = 65536
  add_child(deathRay)
  deathRay.force_raycast_update()
  log.pp(lastSpawnPoint - deathPosition, 'lastSpawnPoint - deathPosition')
  if deathRay.is_colliding():
    log.pp(deathRay.get_collision_point(), 'deathRay.get_collision_point()', deathRay.get_collision_normal())
    tempLastSpawnPoint = (deathRay.get_collision_point() - root.position) \
    + (deathRay.get_collision_normal() * Vector2(4, 33 / 2.0))
  deathRay.queue_free()
  return tempLastSpawnPoint

func _on_bottom_body_entered(body: Node2D) -> void:
  if body not in collsiionOn_bottom:
    collsiionOn_bottom.append(body)
func _on_bottom_body_exited(body: Node2D) -> void:
  if body in collsiionOn_bottom:
    collsiionOn_bottom.erase(body)

func _on_top_body_entered(body: Node2D) -> void:
  if body not in collsiionOn_bottom:
    collsiionOn_top.append(body)
func _on_top_body_exited(body: Node2D) -> void:
  if body in collsiionOn_top:
    collsiionOn_top.erase(body)

func _on_right_body_entered(body: Node2D) -> void:
  if body not in collsiionOn_right:
    collsiionOn_right.append(body)
func _on_right_body_exited(body: Node2D) -> void:
  if body in collsiionOn_right:
    collsiionOn_right.erase(body)

func _on_left_body_entered(body: Node2D) -> void:
  if body not in collsiionOn_left:
    collsiionOn_left.append(body)
func _on_left_body_exited(body: Node2D) -> void:
  if body in collsiionOn_left:
    collsiionOn_left.erase(body)

# func updateCollidingBlocksEntered():
#   log.pp("respawn", (
#     respawnDetectionArea.get_overlapping_bodies()
#     + respawnDetectionArea.get_overlapping_areas()
#   ))
#   for block in (
#     respawnDetectionArea.get_overlapping_bodies()
#     +respawnDetectionArea.get_overlapping_areas()
#   ):
#     if 'root' not in block:
#       log.pp(block, block.id if 'id' in block else 'no id')
#       breakpoint
#     else:
#       block.root._on_body_entered(self , false)
func updateCollidingBlocksExited():
  # log.pp("respawn", (
  #   respawnDetectionArea.get_overlapping_bodies()
  #   + respawnDetectionArea.get_overlapping_areas()
  # ))
  for block in (
    respawnDetectionArea.get_overlapping_bodies()
    + respawnDetectionArea.get_overlapping_areas()
  ):
    if 'root' not in block:
      log.pp(block, block.id if 'id' in block else 'no id')
      breakpoint
    else:
      block.root._on_body_exited(self , false)

func updateKeyFollowPosition(delta):
  for i in range(0, keys.size()):
    var follow_distance = max(3, 30 - i + keys[i].root.randOffset)
    var follower = keys[i].root.thingThatMoves
    var leader = keys[i - 1].root.thingThatMoves if i else self
    var direction = (leader.global_position - follower.global_position).normalized()
    var target_position = leader.global_position - direction * follow_distance
    follower.global_position = lerp(follower.global_position, target_position, .3)
    var rotOffset = deg_to_rad(global.sinFrom(30, -30, i, .2))
    if follower.global_position.x > global_position.x:
      rotOffset = - rotOffset
    follower.global_rotation = lerp_angle(follower.global_rotation, global_rotation + rotOffset, .3)
func applyRot(x: Variant = 0.0, y: float = 0.0) -> Vector2:
  var v
  if x is Vector2:
    v = x.rotated(global.player.defaultAngle)
  else:
    v = Vector2(x, y).rotated(global.player.defaultAngle)
  return global.clearLow(v)

# ?zipline
# ??add tooltips to blocks in block picker

# add animations for
#   lights out
#   levers being active

# add level tags

# fix moving blocks not moving the player correctly

# ????fix spike sizes not being the same

# !!add undo/redo history

# ?allow user to reorder the levels in the editor
# ??allow user to reorder the block picker from editor ui
# ?add required events to win level - eg break x glass - separate ones for each level in a map, not mapwide goals

# option to change ghost opacity/ghost hover opacity? .5

# allow walking up small ledges
# allow grouping editor blocks in the editor bar
# make blocks not move while resizing past min

# known:
  # !version ?-24! when respawning inside water you don't enter the water as collision is disabled while respawning
  # !version ?-INF! kt doesnt reset while entering water
    # vex++:downloadMap/136/rssaromeo/uno mas - water jump
  # ?!version ?-<136! holding down while being bounced by a bouncey then landing right on the ledge will cause you to jump up off the ledge
  # !version ?-NOW! sliding into water causes shrunken hitbox
    # vex++:downloadMap/136/rssaromeo/uno mas - water crouch
  # !version ?-NOW! when leaving water directly onto a wall you can grab the wall lower than intended
  # !version ?-<136! when standing on a box and running into another box, kicking wikk kick both of them leading you to be crushed by the box that gets pushed into you
  # !version ?-28! levers can be pulled even when not on ground
  # ?!version 26-NOW! portal wrongwarp when falling through portals building speed then a moving block moves in your path where you slide on the wall then fall back into the same portal that you were previously using to build speed
  # !version 29-29! dying while pulling levers causes global.tick to stay at 0
  # !version ?-28! pulling levers allows clipping through moving blocks
  # ?!version ?-?! grabbing a ledge backwards then landing on a block causes player to build up speed as if falling without moving
  # !version ?-NOW! can push boxes while sliding
    # vex++:downloadMap/136/rssaromeo/uno mas - slide push
  # ?!version ?-<104! spawnpoint being inside water and doing full restart while in spawn water causes player to not be in water
  # !version ?-63! poles and ziplines would not clear wall state preventing jumping to same wall again
  # !version ?-<104! when jumping off wall nowjs don't prevent wall jumping they only remove the speed reduction
  # !version ?-NOW! exploded bombs reexplode after respawning
  # !version ?-NOW! can pull levers while falling if lever is slightly too high no pull normally
  # !version ?-NOW! when flipping gravity on a wall hang the wall hang state can persist after player rotates to incorrect direction
  # !version ?-INF! collision is not checked while in cannons
  # !version ?-91! ice blocks don't require falling to break
  # !version ?-94! traveling through a goal while dying counts as winning
  # !version ?-105! crouching and dying while on a floor button causes the button to be pressed down until the player represses and releases the button
  # !version ?-113! pulleys and cannons give an extra jump
  # !version ?-113! stars saved block and player data, now they only save block data
  # !version ?-115! getting pushed off a ledge doesn't remove a jump
  # !version ?-<121! riding a pulley as it no longer had a ceiling, or getting dropped off by hitting a block would cause the player to gave an extra jump
  # !version ?-126! respawning with a solar block disabled would cause blocks to not attach to it
    # vex++:downloadMap/125/rssaromeo/uno mas - solar attach bug
  # !version ?-NOW! cpops
  # !version OLD-1-NOW! player direction not reset on death
  # /!version ?-135! negative size spikes don't have a texture
    # vex++:downloadMap/135/rssaromeo/uno mas - invisible spikes - no alpha
  # !version 147-INF! sticky floors don't modify jump count so jump refresher set to +1 can give infinite jumps if collected and the next place landed is a sticky floor
  # ?!version 161-161! attaching more than 2 puleys to each other can sometimes cause a large boost upwards
  # /!version 163-163! dying while on a pulley causes the player y to be that of the pulley instead of the player's spawn point
    # vex++:downloadMap/163/rssaromeo/uno mas - zipline death warp
  # !version ?-NOW! ryding falling blocks into water pulls you down same as if not in water

# ?add level option to change canPressDownToShortHop and make sh work
# make slope grabbox sloped

# add star requirement for inner level
# ?add star finder

# make clicking to release copy not select blocks

# ?stop player from lever when nolonger standing on block
# make it so that if the player dies instantly after respawning stop player process
# allow esc while in text box .prompt
# add more ghost/editorBar costumes for the oneway
# ?add way to change the block picker from the editor
# add extra animation frame to oneway
# -make balanced random
# add reset to default button to settings
# ?add texture to reset buttons
# in rev grav
  # pulleys set animation in wrong direction
  # dying in water causes bad rotation until respawn ends
# -make bouncing buzsaws follow gravity

# -!!!fix scaling of rotated blocks
# ?make ice and have it melt by targeting lasers/lazers
# -make pushable box and bomb and bouncing buzsaw rotation affect their gravity
# +-??add block id viewer to see what ids are used, where the ids are used at and how many times they're used and be able to warp to blocks by selected id. would work for things like portals and buttons and button deactvated walls
# -??!!?make gravity rotators only affect the things that enter them
# ??add powerups
# ?!!when first loading level blocks attach incorrectly until respawn - could be fixed?

# ?grab

# !!fix blocks sometimes ending up near 00
# !!make multi select not trigger on move end

# -add presets to menu options

# -!!fix signal list not removing items when selopt is changed
# ?fix locked box in wall not unlocking
# -fix spike vscaling to not be from center
# -set black theme tooltips bg color
# -nodie star
# -?!!!add block name as tooltip to editor bar
# -make multiselected block rotatable/scalable
# -surprise spike
# -!!update numbers when searching online levels
# -search multiple terms at once
# !!fix bouncy inconsistent bounce height
# !!fix bouncy inconsistent bounce end scale/position
# -add button to add custom key to unavailables
# !!add serarch to level list

# player area detector

# ?make boxes go through portals
# !!add more ways to toggle lights

# signal list only in edit / play opts

# add way to say creators should be higher than versions

# see self signal sending?

# fix path not effected by color

# ??add jump count display on player

# !!add modifiers to readme

# !!!fix no shrink past min size

# fix being able to rotate/scale player

# fix being unable to wallhang in small spaces

# !!!fix box select not worjing on rotated blocks

# when loading level from file open game versiuon that the level is for

# !!!fix player moving when creating basic block

# disable collision on block creation
# add zindex to display options for the hovered block list

# add enum md for settings

# fix path edit node button

# add on create func to blocks

# exit inner level button should trigger a save

# loading in water first time doesn't detect there being water

# add different surican colors

# !!when creating/duping add mouse pos/clone node pos as start location for singale axis alignment and don't scale on shift

# if inner open keep outer open menu onlyOneOpen

# add cp savestate level opt
# ?add roll

# hide block select outline in screenshot

# make autocomplete options clickable

# add way to tell when creator makes new level

# add way to sort and filter online level list

# add way to detect update available for previously downloaded levels

# fix scaling of rotating buzsaw

# -make blocks attach to growing blocks and move and scale with them

# make game version: button open in version

# make animaction correct place on left puley

# !!!fix jumping off ziplines

# !!fix dropping off ziplines

# !!fix randomly slipping off wall slides

# make local level list filter search bar work