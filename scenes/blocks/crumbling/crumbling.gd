@icon("images/base/1.png")
extends EditorBlock
class_name BlockCrumbling

@export var anim: AnimatedSprite2D

var started = false

func start():
  if started: return
  anim.play('default')
  anim.frame = 1
  started = true
  anim.animation_finished.connect(func():
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
