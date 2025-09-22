@icon("images/base/1.png")
extends EditorBlock
class_name BlockCrumbling

@export var anim: AnimatedSprite2D

var started = false
var ended := false

func start():
  if started: return
  anim.play('default')
  anim.frame = 1
  started = true
  anim.animation_finished.connect(func():
    ended=true
    __disable()
    for child in attach_children:
      child.__disable()
  )

func on_respawn():
  started = false
  anim.stop()
  anim.frame = 0
  for child in attach_children:
    child.__enable()

func onSave() -> Array[String]:
  return ['anim.frame', 'anim.frame_progress', 'started', "ended"]

func onDataLoaded() -> void:
  if ended:
    global.player.Alltryaddgroups.connect(func():
      __disable.call_deferred()
      for block: EditorBlock in attach_children:
        block.__disable.call_deferred()
    , Object.CONNECT_ONE_SHOT)
  elif started:
    var lastFrame = anim.frame
    var lastFrameProg = anim.frame_progress
    anim.play('default')
    anim.animation_finished.connect(func():
      ended=true
      __disable()
      for child in attach_children:
        child.__disable()
    )
    anim.set_frame_and_progress(lastFrame, lastFrameProg)