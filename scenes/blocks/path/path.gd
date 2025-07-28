@icon("images/1.png")
extends EditorBlock
class_name BlockPath

var maxProgress: float
const editNodeSpawner = preload("res://scenes/blocks/path/editNode.tscn")

var lastStartTime: float = 0
var started: bool = false
var canRestart: bool = false
var currentTick: float = 0
var savedMovement: float = 0
var lastDesiredPosition: Vector2

enum Restarts {
  never,
  always,
  ifStopped,
}

enum EndReachedActions {
  stop,
  loop,
  reverse,
}

func generateBlockOpts():
  blockOptions.path = {
    "default": "50.0,-100.0,150.0,-100.0,50.0,100.0,-50.0,100.0,0,0",
    "type": global.PromptTypes.string
  }
  blockOptions.endReachedAction = {
    "default": 0,
    "type": global.PromptTypes._enum,
    "values": EndReachedActions,
  }
  blockOptions.startOnLoad = {
    "default": true,
    "type": global.PromptTypes.bool
  }
  blockOptions.startOnPress = {
    "default": false,
    "type": global.PromptTypes.bool,
    'onChange': func(val):
      if val:
        selectedOptions.startWhilePressed = false
        selectedOptions.startWhilePressedBackWhileNotPressed = false
      return true,
  }
  blockOptions.startWhilePressed = {
    "default": false,
    "type": global.PromptTypes.bool,
    'onChange': func(val):
      if val:
        selectedOptions.startOnPress = false
        selectedOptions.startWhilePressedBackWhileNotPressed = false
      return true,
  }
  blockOptions.startWhilePressedBackWhileNotPressed = {
    "default": false,
    "type": global.PromptTypes.bool,
    'onChange': func(val):
      if val:
        selectedOptions.startWhilePressed = false
        selectedOptions.startOnPress = false
      return true,
  }
  blockOptions.signalInputId = {
    "type": global.PromptTypes.int,
    "default": 0,
    'showIf': func():
      return selectedOptions.startOnPress or selectedOptions.startWhilePressed,
  }
  blockOptions.restart = {
    "default": 0,
    "type": global.PromptTypes._enum,
    "values": Restarts,
    'showIf': func():
      return selectedOptions.startWhilePressed or selectedOptions.startOnPress,
  }
  blockOptions.forwardSpeed = {
    "default": 150,
    "type": global.PromptTypes.int,
  }
  blockOptions.backwardSpeed = {
    "default": 150,
    'showIf': func():
      return selectedOptions.endReachedAction == EndReachedActions.reverse,
    "type": global.PromptTypes.int,
  }
  blockOptions.addNewPoint = {
    "type": 'BUTTON',
    "onChange": func():
      path.insert(0, Vector2.ZERO)
      savePath()
      respawn()
  }

var path: Array[Vector2] = []
var pathEditNodes: Array[BlockPath_editNode] = []

func getMaxProgress() -> float:
  var total_distance = 0
  for i in range(1, path.size()):
    total_distance += path[i].distance_to(path[i - 1])
  return total_distance

# func getPointProgress(idx) -> float:
#   if idx < 0 or idx >= path.size():
#     return 0
#   var point_distance = 0
#   for i in range(1, idx + 1):
#     point_distance += path[i].distance_to(path[i - 1])
#   return point_distance

func fromProgressToPoint(prog) -> Vector2:
  var current_distance = 0
  for i in range(1, path.size()):
    var segment_distance = path[i].distance_to(path[i - 1])
    if current_distance + segment_distance >= prog:
      var t = (prog - current_distance) / segment_distance
      return path[i - 1].move_toward(path[i], t * segment_distance)
    current_distance += segment_distance
  return path[path.size() - 1]

func on_physics_process(delta: float) -> void:
  if not started: return
  currentTick = global.tick - lastStartTime + savedMovement
  var isBackwards: bool = selectedOptions.forwardSpeed < 0
  var desiredPosition = (func():
    match selectedOptions.endReachedAction:
      EndReachedActions.stop:
        if (currentTick * abs(selectedOptions.forwardSpeed)) >= maxProgress:
          started = false
          if selectedOptions.restart == Restarts.never:
            canRestart = false
          elif selectedOptions.restart == Restarts.ifStopped:
            canRestart = true

            set_deferred("currentTick", 0)
        if isBackwards:
          return fromProgressToPoint(maxProgress - (currentTick * abs(selectedOptions.forwardSpeed)))
        return fromProgressToPoint(currentTick * abs(selectedOptions.forwardSpeed))
      EndReachedActions.loop:
        var time = fmod(currentTick * abs(selectedOptions.forwardSpeed), maxProgress)
        if isBackwards:
          return fromProgressToPoint(maxProgress - time)
        else:
          return fromProgressToPoint(time)
      EndReachedActions.reverse:
        var forwardTime = maxProgress / abs(selectedOptions.forwardSpeed)
        var backwardTime = maxProgress / abs(selectedOptions.backwardSpeed)
        var time = fmod(currentTick, forwardTime + backwardTime)
        # if isBackwards:
        if time > forwardTime:
          isBackwards = selectedOptions.backwardSpeed < 0
        else:
          isBackwards = selectedOptions.forwardSpeed < 0
        if isBackwards:
          if time <= forwardTime:
            return fromProgressToPoint(maxProgress - (time * abs(selectedOptions.forwardSpeed)))
          else:
            return fromProgressToPoint((time - forwardTime) * abs(selectedOptions.backwardSpeed))
        else:
          if time <= forwardTime:
            return fromProgressToPoint(time * abs(selectedOptions.forwardSpeed))
          else:
            return fromProgressToPoint(maxProgress - ((time - forwardTime) * abs(selectedOptions.backwardSpeed)))
      _: return Vector2.ZERO
    ).call()
  for child in attach_children:
    child.thingThatMoves.global_position += desiredPosition - lastDesiredPosition
  lastDesiredPosition = desiredPosition

func on_ready() -> void:
  if not global.onEditorStateChanged.is_connected(updateVisible):
    global.onEditorStateChanged.connect(updateVisible)

func updateVisible() -> void:
  $Sprite2D.visible = global.useropts.showPathBlockInPlay or global.showEditorUi
  queue_redraw()

func _draw() -> void:
  var lastPoint = global_position
  if global.useropts.showPathLineInPlay or global.showEditorUi:
    for idx in range(len(path)):
      var point = path[idx]
      draw_line(
        to_local(lastPoint),
        to_local(global_position + point),
        global.useropts.pathColor,
        10
      )
      lastPoint = global_position + point

func on_signal_changed(id, on):
  if id == selectedOptions.signalInputId:
    if on:
      if not canRestart: return
      if started:
        if selectedOptions.restart == Restarts.always:
          lastStartTime = global.tick
        else:
          canRestart = false
      else:
        lastStartTime = global.tick
      started = true
    else:
      if selectedOptions.startWhilePressed or selectedOptions.startWhilePressedBackWhileNotPressed:
        started = false
        savedMovement = currentTick

func updatePoint(node: BlockPath_editNode, moveStopped: bool) -> void:
  var idx = pathEditNodes.find(node)
  path[idx + 1] = node.startPosition - global_position
  updateVisible()
  if moveStopped:
    savePath()
    respawn()

func on_respawn():
  if self in global.boxSelect_selectedBlocks: return
  lastDesiredPosition = Vector2.ZERO
  savedMovement = 0
  currentTick = 0
  lastStartTime = 0
  started = selectedOptions.startOnLoad
  canRestart = selectedOptions.restart == Restarts.always
  updateVisible()
  global.onSignalChanged(on_signal_changed)
  maxProgress = getMaxProgress()
  if not isBeingMoved or isBeingPlaced or global.useropts.movingPathNodeMovesEntirePath:
    var p := selectedOptions.path.split(',') as Array
    # start at the paths location
    path = [Vector2.ZERO]
    for node in pathEditNodes:
      node.queue_free()
    pathEditNodes = []
    while len(p) >= 2:
      var newPoint = Vector2(float(p.pop_front()), float(\
      p.pop_front())).rotated(deg_to_rad(startRotation_degrees))
      path.append(newPoint)
      var editNode = editNodeSpawner.instantiate()
      editNode.global_position = newPoint + global_position
      editNode.startPosition = newPoint + global_position
      editNode.path = self
      pathEditNodes.append(editNode)
      global.level.get_node('blocks').add_child(editNode)

func onEditorMove(moveDist: Vector2) -> void:
  super (moveDist)
  if isBeingPlaced or global.useropts.movingPathNodeMovesEntirePath: return
  for i in range(len(path)):
    path[i] -= moveDist
  path[0] = Vector2.ZERO

func onEditorMoveEnded():
  savePath()
  respawn()

func savePath():
  # remove the Vector2.ZERO from the front
  path.pop_front()
  selectedOptions.path = ','.join(
    path.map(func(e): return \
      str(int(e.rotated(-deg_to_rad(startRotation_degrees)).x)) + ',' + \
      str(int(e.rotated(-deg_to_rad(startRotation_degrees)).y))
    )
  )
  path.push_front(Vector2.ZERO)
