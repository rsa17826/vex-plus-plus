@icon("images/editorBar.png")
extends EditorBlock
class_name BlockRotator

func generateBlockOpts():
  blockOptions.signalInputId = {"type": global.PromptTypes.int, "default": 0}
  blockOptions.speed = {"type": global.PromptTypes.float, "default": 50}

var rotating = false

func onSignalChanged(id, on, callers):
  if self in callers: return
  if id == selectedOptions.signalInputId:
    rotating = on

func on_respawn():
  log.pp("on_respawn")
  rotating = false
  rotation = 0
  global.onSignalChanged(onSignalChanged)

func on_physics_process(delta: float) -> void:
  if rotating:
    thingThatMoves.rotation_degrees += selectedOptions.speed * delta
    for block in attach_children:
      var offset = block.thingThatMoves.global_position - thingThatMoves.global_position
      # block.thingThatMoves.rotation_degrees += selectedOptions.speed
      var newpos = thingThatMoves.global_position + \
      (offset) \
      .rotated(deg_to_rad(selectedOptions.speed * delta))
      block.thingThatMoves.global_position += newpos - block.thingThatMoves.global_position
