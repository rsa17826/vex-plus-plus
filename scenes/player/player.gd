extends CharacterBody2D
class_name Player

# @name same line return
# @regex :\s*(return|continue|break)\s*$
# @replace : $1
# @flags gm
# @endregex

const GRAVITY = 1280
const MAX_PULLEY_NO_DIE_TIME = 50
const MOVESPEED = 220
const JUMP_POWER = -430
const MAX_WALL_SLIDE_FRAMES = 120
const MAX_SLIDE_RECOVER_TIME = 14
const MAX_WALL_BREAK_FROM_DOWN_FRAMES = 10
const MAX_KT_TIMER = 5
const MAX_WATER_KT_TIMER = 5
const WATER_TURNSPEED = 170
const WATER_MOVESPEED = 4000
const WATER_EXIT_BOUNCE_FORCE = -600
const WALL_SLIDE_SPEED = 35
const DEATH_TIME = 15
const MAX_BOX_KICK_RECOVER_TIME = 22

var deathSources := []
var pulleyNoDieTimer: float = 0
var currentRespawnDelay: float = 0
var activePulley: Node2D = null
var activePole: Node2D = null
var playerXIntent: float = 0
var lastWall := 0
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

var lightsOut: bool = false

var keys: Array = []

var collsiionOn_top := []
var collsiionOn_bottom := []
var collsiionOn_left := []
var collsiionOn_right := []

var lastSpawnPoint := Vector2(0, 0)

var moving := 0

var inWaters: Array = []
var lastCollidingBlocks: Array = []

var ACTIONjump: bool = false:
  get():
    if ACTIONjump:
      ACTIONjump = false
      return true
    return ACTIONjump

var vel := {
  "pole": Vector2.ZERO,
  "user": Vector2.ZERO,
  "waterExit": Vector2.ZERO,
  "bounce": Vector2.ZERO,
}
var velDecay := {
  "pole": 1,
  "user": 1,
  "waterExit": .9,
  "bounce": 0.95,
}
var justAddedVels := {
  "pole": 0,
  "user": 0,
  "waterExit": 0,
  "bounce": 0,
}
var stopVelOnGround := ["bounce", "waterExit"]
var stopVelOnWall := ["bounce", "waterExit"]
var stopVelOnCeil := ["bounce", "waterExit"]

@onready var unduckSize: Vector2 = Vector2(8, 33) # $CollisionShape2D.shape.size
@onready var unduckPos: Vector2 = Vector2.ZERO # $CollisionShape2D.position

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
  levelLoading,
}

var isFakeMouseMovement: bool = false
var camState: CamStates = CamStates.player
enum CamStates {
  player,
  editor,
}

var gravState: GravStates = GravStates.normal
enum GravStates {
  up,
  down,
  normal
}

func _init() -> void:
  global.player = self

func _ready() -> void:
  Input.mouse_mode = mouseMode

func _input(event: InputEvent) -> void:
  if event is InputEventMouseMotion and event.relative == Vector2.ZERO: return
  if event is InputEventMouseMotion and isFakeMouseMovement:
    isFakeMouseMovement = false
    return
  # log.pp(event.to_string(), global.showEditorUi)
  if global.openMsgBoxCount: return
  if Input.is_action_just_pressed(&"restart"):
    die()
  if Input.is_action_just_pressed(&"full_restart"):
    die(DEATH_TIME, true)
  if event is InputEventMouseMotion:
    global.showEditorUi = true
  if Input.is_action_pressed(&"editor_pan"):
    global.showEditorUi = true
    Input.set_default_cursor_shape(Input.CURSOR_DRAG)
  else:
    if global.showEditorUi:
      Input.set_default_cursor_shape(Input.CURSOR_ARROW)
    else:
      mouseMode = Input.MOUSE_MODE_CONFINED_HIDDEN

  # if event is InputEventMouseButton:
  if event is InputEventMouseMotion and event.screen_relative:
    if state == States.dead \
    and mouseMode != Input.MOUSE_MODE_CONFINED: return
    mouseMode = Input.MOUSE_MODE_CONFINED
    camState = CamStates.editor
    $Camera2D.reset_smoothing()
    if Input.is_action_pressed(&"editor_select") and Input.is_action_pressed(&"editor_pan"):
      $Camera2D.global_position -= event.relative * global.useropts.editorScrollSpeed
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
    camLockPos = $Camera2D.global_position

  if state != States.dead and global.showEditorUi:
    for action: String in ["right", "jump", "left"]:
      if Input.is_action_pressed(action, true):
        global.showEditorUi = false
        camState = CamStates.player
        camLockPos = Vector2.ZERO
        # $Camera2D.position_smoothing_enabled = true
        $Camera2D.position = Vector2.ZERO
        break

  if mouseMode == Input.mouse_mode: return
  Input.mouse_mode = mouseMode

func _process(delta: float) -> void:
  if global.openMsgBoxCount: return
  if camLockPos:
    $Camera2D.global_position = camLockPos
    $Camera2D.reset_smoothing()

func _physics_process(delta: float) -> void:
  if state == States.levelLoading: return
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
    # States.levelLoading,
  ] \
  and not inWaters:
    if Input.is_action_just_pressed(&"jump"):
      ACTIONjump = true
  if !Input.is_action_pressed(&"jump"):
    ACTIONjump = false
  var onStickyFloor = %stickyFloorDetector.get_overlapping_areas()
  # Engine.time_scale = .3
  Engine.time_scale = 1
  if global.openMsgBoxCount: return
  if Input.is_action_pressed(&"editor_select"):
    if get_parent() in global.boxSelect_selectedBlocks:
      position = Vector2.ZERO
    return
  var frameStartPosition := global_position
  $waterRay.rotation_degrees = - rotation_degrees
  $anim.position = Vector2(0, 0.145)
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
      deadTimer -= delta * 60
      deadTimer = clampf(deadTimer, 0, currentRespawnDelay)
      # global.tick = global.currentLevel().tick
      if currentRespawnDelay == 0:
        position = lastSpawnPoint
      else:
        position = global.rerange(deadTimer, currentRespawnDelay, 0, deathPosition, lastSpawnPoint)
      pulleyNoDieTimer = 0
      inWaters = []
      # Engine.time_scale = clampf(global.rerange(deadTimer, currentRespawnDelay, 0, 4, .001), .001, 4)
      $anim.animation = "die"
      rotation = lerp_angle(float(rotation), 0.0, .2)
      $CollisionShape2D.rotation = - rotation
      # hide the water animations
      $anim.visible = true
      $waterAnimTop.visible = false
      $waterAnimBottom.visible = false
      $Camera2D.reset_smoothing()
      if deadTimer <= 0:
        if lastSpawnPoint:
          position = lastSpawnPoint
        else:
          position = Vector2(0, -1.9)
        state = States.falling
        Engine.time_scale = 1
        await global.wait()
        updateCollidingBlocksEntered()
        global.stopTicking = false
      return
    States.swingingOnPole:
      rotation = 0
      $CollisionShape2D.rotation = 0
      # rotation += 6 * delta
      global_position = activePole.global_position
      $anim.animation = "on pole"
      playerKT = 0
      vel.user = Vector2.ZERO
      $CollisionShape2D.shape.size.y = unduckSize.y / 4
      %deathDetectors.scale = Vector2(1, 0.25)

      var xIntent = Input.get_axis("left", "right")
      if xIntent > 0:
        $anim.flip_h = false
      elif xIntent < 0:
        $anim.flip_h = true
      if $anim.flip_h:
        activePole.root.timingIndicator.rotation_degrees = 135 # - activePole.root.timingIndicator.get_parent().rotation_degrees
        activePole.root.timingIndicator.position = Vector2(-55.5, 55.5)
      else:
        activePole.root.timingIndicator.rotation_degrees = 45 # - activePole.root.timingIndicator.get_parent().rotation_degrees
        activePole.root.timingIndicator.position = Vector2(55.5, 55.5)
      if Input.is_action_just_pressed(&"jump"):
        if $anim.frame >= 1 and $anim.frame <= 5:
          # this one should be user because it makes the falling better
          vel.user.y = JUMP_POWER
          # but this should be pole as that way it does something as user.x is set to xintent
          vel.pole.x = 50 * (-1 if $anim.flip_h else 1)
          $anim.animation = "jumping off pole"
          $anim.animation_looped.connect(func():
            if $anim.animation == "jumping off pole":
              $anim.animation="jump",
            Object.CONNECT_ONE_SHOT)
          state = States.jumping
        else:
          vel.user.y = 0
          state = States.falling
        activePole.root.timingIndicator.visible = false
        activePole = null
      elif Input.is_action_just_pressed(&"down"):
        vel.user.y = 0
        activePole.root.timingIndicator.visible = false
        activePole = null
        state = States.falling
      tryAndDieHazards()
      tryAndDieSquish()
    States.onPulley:
      rotation = lerp_angle(float(rotation), 0.0, .2)
      $CollisionShape2D.rotation = - rotation
      vel.user = Vector2.ZERO
      var lastpos := global_position
      global_position = activePulley.nodeToMove.global_position + Vector2(0, 13)
      $anim.position = Vector2(5, 5.145)
      $anim.position.x *= activePulley.direction
      $anim.flip_h = activePulley.direction == -1
      if pulleyNoDieTimer <= 0:
        $anim.animation = "on pulley"
        if ACTIONjump:
          pulleyNoDieTimer = MAX_PULLEY_NO_DIE_TIME
          $anim.animation = "pulley invins"
      else:
        pulleyNoDieTimer -= delta * 60
        if pulleyNoDieTimer <= 0:
          $anim.animation = "on pulley"
          $anim.frame = 9
      if collsiionOn_right or collsiionOn_left:
        activePulley.respawn()
        global_position = lastpos
      # log.pp(pulleyNoDieTimer)
      if pulleyNoDieTimer <= 0:
        tryAndDieHazards()

      if Input.is_action_just_pressed(&"down") or inWaters:
        state = States.falling
    States.bouncing:
      rotation = 0
      $CollisionShape2D.rotation = 0
      lastWall = 0
      breakFromWall = false
      wallSlidingFrames = 0
      slideRecovery = 0
      duckRecovery = 0
      wallBreakDownFrames = 0
      $anim.animation = "duck start"
      vel.user.y = 0
      return
    States.pullingLever:
      rotation = 0
      $CollisionShape2D.rotation = 0
      $anim.animation = "pulling lever"
      $anim.animation_looped.connect(func() -> void:
        if state == States.dead: return
        state=States.idle, Object.CONNECT_ONE_SHOT)
      tryAndDieHazards()
      tryAndDieSquish()
    _:
      if inWaters:
        floor_snap_length = 0
        # show the water animations
        $CollisionShape2D.rotation = 0
        $waterAnimTop.visible = true
        $waterAnimBottom.visible = true
        $anim.visible = false
        # turn player
        rotation_degrees += delta * WATER_TURNSPEED * Input.get_axis("left", "right")
        # dont store velocity from normal movement if in water
        vel.user = Vector2.ZERO
        # set state to falling for when player exits the water
        state = States.falling
        # move forward or backward based on input
        velocity += Vector2(-transform.y) * delta * WATER_MOVESPEED * Input.get_axis("down", "jump")
        velocity *= .8
        # only bounce out of the water if going up
        for v: String in vel:
          vel[v] = Vector2.ZERO
        if $waterRay.is_colliding():
          vel.waterExit = Vector2(0, WATER_EXIT_BOUNCE_FORCE).rotated(rotation)
        # reset some variables to allow player to grab both walls when exiting water
        playerXIntent = 0
        lastWall = 0
        breakFromWall = false
        wallSlidingFrames = 0
        slideRecovery = 0
        duckRecovery = 0
        wallBreakDownFrames = 0
        # can be used to prevent pressing jump quickly again after exiting water to get ~2x height
        # playerKT = 0
        if playerKT:
          playerKT = MAX_WATER_KT_TIMER
        for i in get_slide_collision_count():
          var collision := get_slide_collision(i)
          var block := collision.get_collider()

          var normal := collision.get_normal()
          var depth := collision.get_depth()
          handleCollision(block, normal, depth, true)

        wasJustInWater = true
        move_and_slide()
        tryAndDieHazards()
      else:
        if vel.pole:
          vel.pole.x -= 2 * sign(vel.pole.x) * delta * 60
          # if abs(vel.pole.x) < 5:
          #   vel.pole.x = 0

        floor_snap_length = 5
        # reset angle when exiting water
        rotation = lerp_angle(float(rotation), 0.0, .2)
        $CollisionShape2D.rotation = - rotation
        if state == States.wallHang:
          if (CenterIsOnWall() and !TopIsOnWall()):
            state = States.falling
        # hide the water animations
        $anim.visible = true
        $waterAnimTop.visible = false
        $waterAnimBottom.visible = false

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
        if boxKickRecovery > 0:
          boxKickRecovery -= delta * 60
          if boxKickRecovery <= 0:
            position.y += 1
          return

        if state == States.wallHang || state == States.wallSliding:
          if not is_on_wall() and getClosestWallSide():
            var ray: RayCast2D
            match getClosestWallSide():
              1:
                ray = $wallDetection/rightWall
              -1:
                ray = $wallDetection/leftWall

            var origin: Vector2 = ray.global_transform.origin
            var collision_point := ray.get_collision_point()
            var distance := origin.distance_to(collision_point)
            # log.pp(distance * getClosestWallSide())
            position.x += (distance) * getClosestWallSide()
        # if on floor reset kt, user y velocity, and allow both wall sides again
        if is_on_floor():
          if !onStickyFloor:
            playerKT = MAX_KT_TIMER
          vel.user.y = 0
          lastWall = 0
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
          if lastWall && (getCurrentWallSide() && lastWall != getCurrentWallSide()):
            lastWall = 0
            breakFromWall = false
            state = States.wallSliding
          if state != States.wallHang:
            currentHungWall = 0
          # should enter wall grab state if not already in wall hang state and moving down
          # log.pp(velocity.y)
          if velocity.y > -20 && state != States.wallHang:
            # log.pp("entering wall grab", CenterIsOnWall(), TopIsOnWall())
            if CenterIsOnWall() && !TopIsOnWall() and not %nowjDetector.get_overlapping_bodies():
              currentHungWall = $wallDetection/rightWall.get_collider() if getCurrentWallSide() == 1 else $wallDetection/leftWall.get_collider()
              hungWallSide = getCurrentWallSide()
              state = States.wallHang
              var loopIdx: int = 0
              while !TopIsOnWall() and loopIdx < 20:
                loopIdx += 1
                position.y += 1
                $wallDetection/leftWallTop.force_raycast_update()
                $wallDetection/rightWallTop.force_raycast_update()
              if loopIdx >= 20:
                position.y -= loopIdx
                log.pp("fell off wall hang")
                state = States.falling
              position.y -= 5
              breakFromWall = true
              lastWall = 0

          # if not in wall hang state and near a wall
          if state != States.wallHang && getCurrentWallSide():
            lastWall = getCurrentWallSide()
          if CenterIsOnWall() && not is_on_floor() && !breakFromWall \
          && velocity.y > 0 && wallBreakDownFrames <= 0 \
          and not %nowjDetector.get_overlapping_bodies():
            vel.user.y = WALL_SLIDE_SPEED
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
            vel.user.y += REAL_GRAV

        if breakFromWall:
          wallSlidingFrames = 0
        # jump from walljump
        if state == States.wallSliding and ACTIONjump && !breakFromWall and not onStickyFloor:
          state = States.jumping
          breakFromWall = true
          vel.user.y = JUMP_POWER
        if (state == States.wallHang) && is_on_wall_only() && CenterIsOnWall():
          vel.user.y = 0
          wallSlidingFrames = 0
          breakFromWall = false
          # press down to detach from wallhang
          if Input.is_action_pressed(&"down"):
            position.y += 5
            wallBreakDownFrames = MAX_WALL_BREAK_FROM_DOWN_FRAMES
            state = States.falling

        # jump from wall grab or from the ground
        if !Input.is_action_pressed(&"down"):
          if (playerKT > 0) || state == States.wallHang:
            if not onStickyFloor:
              if duckRecovery <= 0 and ACTIONjump:
                state = States.jumping
                playerKT = 0
                vel.user.y = JUMP_POWER

        # if not in duckRecovery or wall hang or wallSliding, allow movement
        if (!breakFromWall and (state == States.wallSliding || state == States.wallHang)) \
          or duckRecovery > 0:
          playerXIntent = 0
        else:
          playerXIntent = MOVESPEED * Input.get_axis("left", "right") * \
          (2 if speedLeverActive else 1)

        # enter slide mode when pressing down key and on the ground
        if is_on_floor() && Input.is_action_pressed(&"down"):
          state = States.sliding

        # check for falling
        if !is_on_floor() && !is_on_wall() && (!(($wallDetection/leftWall.is_colliding() || $wallDetection/rightWall.is_colliding()))):
          if vel.user.y < 0:
            state = States.jumping
          else:
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
          $CollisionShape2D.shape.size.y = unduckSize.y / 2
          $CollisionShape2D.position.y = unduckPos.y + (unduckSize.y / 4)
          %deathDetectors.scale = Vector2(1, 0.5)
          %deathDetectors.position.y = (unduckSize.y / 4)
        else:
          $CollisionShape2D.shape.size.y = unduckSize.y
          $CollisionShape2D.position.y = unduckPos.y
          %deathDetectors.scale = Vector2(1, 1)
          %deathDetectors.position.y = 0

        # animations
        if $anim.animation == "jumping off pole" and vel.user.y != 0:
          pass
        else:
          if duckRecovery > 0:
            $anim.animation = "duck end"
          elif slideRecovery > 0:
            $anim.animation = "slide end"
          else:
            match state:
              States.idle:
                $anim.animation = "idle"
              States.moving:
                $anim.animation = "run"
              States.jumping:
                $anim.animation = "jump"
              States.falling:
                $anim.animation = "jump"
              States.wallSliding:
                if breakFromWall:
                  $anim.animation = "jump"
                else:
                  $anim.animation = "wall slide"
              States.sliding:
                if abs(vel.user.x) < 10:
                  $anim.animation = "duck start"
                else:
                  $anim.animation = "slide start"
              States.wallHang:
                $anim.animation = "wall hang"
              States.pushing:
                $anim.animation = "pushing box"
              _:
                $anim.animation = "idle"

        # set the sprite direction based on velocity
        if vel.user.x > 0:
          $anim.flip_h = false
        elif vel.user.x < 0:
          $anim.flip_h = true

        # when trying to slide, if not moving enough, duck instead
        if state == States.sliding:
          # if sliding reduce speed reuction
          if abs(vel.user.x) < 10:
            vel.user.x = 0
          vel.user.x *= 0.98 # * delta * 60
        # if state is not sliding
        else:
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
          if vel['user'].y < 0:
            vel['user'].y = 0
          for n: String in stopVelOnCeil:
            if !justAddedVels[n]:
              vel[n] = Vector2.ZERO

        # move using all velocities
        # var start = position
        velocity = Vector2.ZERO
        if state != States.wallHang:
          for n: String in vel:
            velocity += vel[n]
          for n: String in vel:
            vel[n] *= velDecay[n] # * delta * 60
        if state == States.wallHang and not getClosestWallSide():
          state = States.falling
        # prevents getting stuck when jumping into a wall, then turning away from the wall, causing you to not move X even tho you have velocity X and still have same velocity X after the moveansslide call
        if state == States.wallSliding:
          position.x += velocity.x * delta
        for n: String in vel:
          if justAddedVels[n]:
            justAddedVels[n] -= 1
        # if !global.showEditorUi:
        #   var maxVel: float = max(abs(velocity.x), abs(velocity.y))
        #   $Camera2D.position_smoothing_enabled = maxVel < 3500
        #   $Camera2D.position_smoothing_speed = global.rerange(maxVel, 0, 6500, 5, 20)
        move_and_slide()
        # get_position_delta( )
        # position -= get_platform_velocity() * delta
        # if is_on_floor() and get_last_slide_collision():
        #   log.pp(get_last_slide_collision().get_depth() * get_floor_normal())
        #   position.y += get_last_slide_collision().get_depth()
        # Update the position of the first follower to follow the main node
        # log.pp(position - (start + (velocity*delta)))
        # # log.pp(
        # #   is_on_wall(),
        # #   CenterIsOnWall(),
        # #   velocity.x,
        # #   state == States.wallSliding,
        # #   state,Array
        # #   vel.user.x,
        # #   playerXIntent
        # # )
        # var posOffset = Vector2.ZERO
        # collision when on floor and moving down
        # floor_max_angle = deg_to_rad(5.0 if state == States.sliding else 49.7)
        # log.pp(floor_max_angle)
        var floorRayCollision: Node2D = null
        if $floorRay.is_colliding():
          floorRayCollision = $floorRay.get_collider()
        # var normals = {
        #   "l": false,
        #   "r": false,
        #   "u": false,
        #   "d": false
        # }
        var currentCollidingBlocks: Array = []
        for i in get_slide_collision_count():
          var collision := get_slide_collision(i)
          var block := collision.get_collider()

          var normal := collision.get_normal()
          var depth := collision.get_depth()
          # log.pp(block.id if 'id' in block else block.get_parent().id, normal, depth, block == floorRayCollision)

          # Store the current colliding blocks
          currentCollidingBlocks.append([block, normal, depth])
          if block == floorRayCollision:
            floorRayCollision = null
          # if normal.x < 0:
          #   normals.l = true
          # if normal.x > 0:
          #   normals.r = true
          # if normal.y > 0:
          #   normals.u = true
          # if normal.y < 0:
          #   normals.d = true
          # Call handleCollision for currently colliding blocks
          handleCollision(block, normal, depth, true)

        # Check for blocks that were colliding last frame but are not colliding now
        # for thing in lastCollidingBlocks:
        #   var block = thing[0]
        #   if !is_instance_valid(block): return
        #   var normal = thing[1]
        #   var depth = thing[2]
        #   if block not in currentCollidingBlocks:
        #     if block.root.lastMovementStep \
        #     and getClosestWallSide() \
        #     and (getClosestWallSide() > 0) == (block.root.lastMovementStep.x > 0) \
        #     and normal.x and getClosestWallSide():
        #       log.pp("Wall collision detected", getClosestWallSide(), block.root.lastMovementStep.x)
        #       posOffset += handleCollision(block, normal, depth, false)

        # Update the last colliding blocks for the next frame
        lastCollidingBlocks = currentCollidingBlocks

        if floorRayCollision:
          handleCollision(floorRayCollision, Vector2(0, -1), 1, true)

        # move_and_collide(posOffset)
        # log.pp(posOffset)
        # position = start
        # position += posOffset
        # move_and_slide()
        # if posOffset:
          # position -= velocity * delta
        # move_and_slide()
        # position += velocity * delta
        # var col = move_and_collide(sign(posOffset))
        # if col:
        #   position -= col.get_normal()
        #   position += sign(posOffset)

        # if state == States.wallSliding and not is_on_wall() and getClosestWallSide():
        #   position.x += getClosestWallSide()
        # if state != States.wallSliding and CenterIsOnWall() and TopIsOnWall() and getClosestWallSide() and not is_on_floor():
        #   state = States.wallSliding
        # log.pp(normals)
        # die when squished
        # if (normals.u and normals.d) \
        # or (normals.l && normals.r):
        #   # breakpoint
        #   die()
        tryAndDieHazards()
        tryAndDieSquish()
      updateKeyFollowPosition(delta)
      
  if !global.showEditorUi:
    var changeInPosition: Vector2 = global_position - frameStartPosition
    var maxVel: float = max(abs(changeInPosition.x), abs(changeInPosition.y)) * delta * 60
    if maxVel > 50:
      $Camera2D.position_smoothing_enabled = false
    else:
      $Camera2D.position_smoothing_enabled = true
      $Camera2D.position_smoothing_speed = clamp(maxVel, 5, 50)
    # var smoothingFactor: float = global.rerange(maxVel, 0, 400, 5, 19)

    # smoothingFactor = clamp(smoothingFactor, 5, 19)

    # var startPos = $Camera2D.position
    # $Camera2D.position = changeInPosition
    if maxVel > 5:
      $Camera2D.position -= ($Camera2D.position - changeInPosition) * 15 * delta
    # Vector2(
    #   pow(changeInPosition.x,1) * 3.7,
    #   pow(changeInPosition.y,1) * 3.7
    # )
    # # $Camera2D.position -= $Camera2D.position * delta * 20
    # if ($Camera2D.position.x > 0) != (startPos.x > 0):
    #   $Camera2D.position.x = 0
    # if ($Camera2D.position.y > 0) != (startPos.y > 0):
    #   $Camera2D.position.y = 0
    # $Camera2D.position_smoothing_speed = smoothingFactor
    $Camera2D.position -= $Camera2D.position * .5 * delta
    # log.pp($Camera2D.position, changeInPosition)

    # log.pp($Camera2D.position_smoothing_speed, maxVel)

func tryAndDieHazards():
  if len(deathSources.filter(func(e):
    return !e.respawning)):
    die()
func tryAndDieSquish():
  if (len(collsiionOn_top) and len(collsiionOn_bottom)) \
  or (len(collsiionOn_left) and len(collsiionOn_right)):
    log.pp(collsiionOn_top, collsiionOn_bottom, collsiionOn_left, collsiionOn_right)
    die()

func handleCollision(b: Node2D, normal: Vector2, depth: float, sameFrame: bool) -> void:
  var block: EditorBlock = b.root
  # var posOffset = Vector2.ZERO
  # log.pp(block.get_groups())
  if block.respawning: return
  if sameFrame:
    if (
      block is BlockDonup
      or block is BlockFalling
    ) \
    and normal.y < 0 \
    and velocity.y >= 0 \
    :
      block.falling = true
    if block is BlockGlass \
    and normal.y < 0 \
    and velocity.y >= 0 \
    and vel.user.y > 0 \
    and Input.is_action_pressed(&"down") \
    :
      block.__disable()
    if block is BlockBouncy \
    and normal.y < 0 \
    and velocity.y >= 0 \
    and not inWaters \
    :
      block.start()
    if block is BlockInnerLevel \
    and normal.y < 0 \
    and state == States.sliding \
    and abs(vel.user.x) < 10 \
    :
      block.enterLevel()
    if block is BlockLockedBox \
    :
      block.unlock()
    if (block is BlockPushableBox or block is BlockBomb) \
    and getClosestWallSide() \
    and Input.is_action_just_pressed(&"down") \
    and not inWaters \
    and normal.y \
    :
      block.thingThatMoves.velocity.x -= getClosestWallSide() * 120
      $anim.animation = "kicking box"
      boxKickRecovery = MAX_BOX_KICK_RECOVER_TIME
      position.y -= 1

    if (block is BlockPushableBox or block is BlockBomb) \
    and is_on_floor() \
    and normal.x \
    and not inWaters \
    :
      block.thingThatMoves.velocity.x -= normal.x * depth * 200
      state = States.pushing
      $anim.animation = "pushing box"

  # if !block.root.lastMovementStep: return
  # if block.is_in_group("falling"):
  #   position.y += block.root.lastMovementStep.y / 4
  # else:
  #   log.pp(block.root.lastMovementStep.y)
  # fixes falling thru blocks visually, but collision not changed
  # position += block.lastMovementStep
  #   if str(normal / abs(normal)) == str(block.root.lastMovementStep / abs(block.root.lastMovementStep)):
  #     log.pp("closer", depth, block.root.lastMovementStep)
  #     posOffset = Vector2.ZERO
  #     posOffset += block.root.lastMovementStep
  #     posOffset -= sign(block.root.lastMovementStep) * 1.1
  #   else:
  #     posOffset += block.root.lastMovementStep

  #   if normal.x:
  #     posOffset.y /= 4.0
  #   # posOffset += block.root.lastMovementStep / 4
  #   # if state != States.wallSliding && state != States.wallHang:
  #   #   posOffset.y = 0
  #   # if posOffset.y:
  #   #   if CenterIsOnWall():
  #   #     if state == States.wallHang || state == States.wallSliding:
  #   #       posOffset += posOffset / 2
  # return posOffset
  # return Vector2.ZERO

  # log.err(posOffset)
  # state = States.falling
  # breakpoint

func goto(pos: Vector2) -> void:
  position = pos
  vel.user = Vector2.ZERO
  $Camera2D.position = Vector2.ZERO
  $Camera2D.reset_smoothing()

func TopIsOnWall() -> bool:
  return is_on_wall() && ($wallDetection/leftWallTop.is_colliding() || $wallDetection/rightWallTop.is_colliding())
func CenterIsOnWall() -> bool:
  return is_on_wall() && ($wallDetection/leftWall.is_colliding() || $wallDetection/rightWall.is_colliding())
func BottomIsOnWall() -> bool:
  return is_on_wall() && ($wallDetection/leftWallBottom.is_colliding() || $wallDetection/rightWallBottom.is_colliding())

func getCurrentWallSide() -> int:
  if !is_on_wall(): return 0
  return getClosestWallSide()
func getClosestWallSide() -> int:
  if $wallDetection/rightWall.is_colliding(): return 1
  if $wallDetection/leftWall.is_colliding(): return -1
  return 0

var OnPlayerDied: Array = []
var OnPlayerFullRestart: Array = []

func die(respawnTime: int = DEATH_TIME, full:=false) -> void:
  log.pp("Player died", respawnTime, full, "lastSpawnPoint", lastSpawnPoint)
  updateCollidingBlocksExited()
  if full:
    lastSpawnPoint = Vector2(0, 0)
    global.tick = 0
    global.currentLevel().tick = 0
  else:
    global.tick = global.currentLevel().tick
  lastCollidingBlocks = []
  activePulley = null
  global.stopTicking = true
  deadTimer = max(respawnTime, 0)
  currentRespawnDelay = respawnTime
  gravState = GravStates.normal
  deathPosition = position
  if state != States.levelLoading:
    state = States.dead
  keys = []
  for v: String in vel:
    vel[v] = Vector2.ZERO
  velocity = Vector2.ZERO
  playerXIntent = 0
  lastWall = 0
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
  lightsOut = false
  speedLeverActive = false
  deathSources = []
  global.lastPortal = null
  OnPlayerDied = OnPlayerDied.filter(func(e: Callable) -> bool:
    return e.is_valid())
  OnPlayerFullRestart = OnPlayerFullRestart.filter(func(e: Callable) -> bool:
    return e.is_valid())
  for cb in OnPlayerDied:
    cb.call()
  if full:
    for cb in OnPlayerFullRestart:
      cb.call()
  _physics_process(0)

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

func updateCollidingBlocksEntered():
  # log.pp("respawn", %"respawn detection area".get_overlapping_bodies())
  for block in (
    %"respawn detection area".get_overlapping_bodies()
    +%"respawn detection area".get_overlapping_areas()
  ):
    if 'root' not in block:
      log.pp(block, block.id if 'id' in block else 'no id')
      breakpoint
    else:
      block.root._on_body_entered(self, false)
func updateCollidingBlocksExited():
  # log.pp("respawn", %"respawn detection area".get_overlapping_bodies())
  for block in (
    %"respawn detection area".get_overlapping_bodies()
    +%"respawn detection area".get_overlapping_areas()
  ):
    if 'root' not in block:
      log.pp(block, block.id if 'id' in block else 'no id')
      breakpoint
    else:
      block.root._on_body_exited(self, false)

func updateKeyFollowPosition(delta):
  for i in range(0, keys.size()):
    var follow_distance = max(3, 30 - i + keys[i].root.randOffset)
    var follower = keys[i].root.thingThatMoves
    var leader = keys[i - 1].root.thingThatMoves if i else self
    var direction = (leader.global_position - follower.global_position).normalized()
    var target_position = leader.global_position - direction * follow_distance
    follower.global_position = lerp(follower.global_position, target_position, .3)

# zipline
# add tooltips to blocks in block picker??
# make menu show groups as named colapsables

# add animations for
#   lights out

# add level tags

# fix moving blocks not moving the player correctly

# add way to change block layer - ignore layers of blocks that arnt colliging with selected block to make layer switching quicker

# fix spike sizes not being the same

# save more than 1 star
# save block state data when saving mid level
# add undo/redo history

# add block animations?
# allow user to reorder the levels in the editor?
# allow user to reorder the block picker?
# add required events to win level? - eg break x glass - separate ones for each level in a map, not mapwide goals

# option to change ghost opacity/ghost hover opacity? .5

# allow walking up small ledges
# allow grouping editor blocks in the editor bar
# make blocks not move while resizing past min

# known:
  # !version ?-24! when respawning inside water you don't enter the water as collision is disabled while respawning
  # !version ?-INF! kt doesnt reset while entering water
  # !version ?-NOW! holding down while being bounced by a bouncey then landing right on the ledge will cause you to jump up off the ledge
  # !version ?-NOW! sliding into water causes shrunken hitbox
  # !version ?-NOW! when leaving water directly onto a wall you can grab the wall lower than intended
  # !version ?-NOW! when standing on a box and running into another box, kicking wikk kick both of them leading you to be crushed by the box that gets pushed into you
  # !version ?-28! levers can be pulled even when not on ground
  # ?!version 26-NOW! portal wrongwarp when falling through portals building speed then a moving block moves in your path where you slide on the wall then fall back into the same portal that you were previously using to build speed
  # !version 29-29! dying while pulling levers causes global.tick to stay at 0
  # !version ?-28! pulling levers allows clipping through moving blocks
  # ?!version ?-?! grabbing a ledge backwards then landing on a block causes player to build up speed as if falling without moving
  # ?!version ?-NOW! can push boxes while sliding
  # ?!version ?-NOW! spawnpoint being inside water and doing full restart while in spawn water causes player to noe be in water

# add level option to change canPressDownToShortHop and make sh work
# make slope grabbox sloped
# add invinsabliity lever?

# add level thumbnails

# add star requirement for inner level
# show on inner level if level has star or not
# save stars that are collected by id, and show collected count
# add star finder?

# add cmd arg to play level by name/path

# add nojump floor
# add 2x jump option?

# make clicking to release copy not select blocks

# make pole quadrent pole indicators rotate correctly

# !!key to exit level
# ?stop player from lever when nolonger standing on block
# prevent pole access while in water
# make it so that if the palyer dies instantly after respawning stop player process
# player not reenter pulley when respawning
# make move_selected_left work