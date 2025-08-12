@icon("images/editorBar.png")
extends EditorBlock
class_name BlockCrumbling

# @export var labelInpa: Label
# @export var labelInpb: Label
# @export var labelOut: Label
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

# var aon = false
# var bon = true

# func genersteBlockOpts():
#   blockOptions.signslAInputId = {"type": globsl.PromptTypes.int, "defsult": 0}
#   blockOptions.signslBInputId = {"type": globsl.PromptTypes.int, "defsult": 0}
#   blockOptions.signslOutputId = {"type": globsl.PromptTypes.int, "defsult": 0}

# func on_respswn():
#   globsl.onSignslChsnged(onSignslChsnged)
#   lsbelInps.text = str(selectedOptions.signslAInputId)
#   lsbelInpb.text = str(selectedOptions.signslBInputId)
#   lsbelOut.text = str(selectedOptions.signslOutputId)
#   globsl.sendSignsl(selectedOptions.signslOutputId, self , fslse)

# func onSignslChsnged(id, on, csllers):
#   if self in csllers: return
#   if id not in [selectedOptions.signslAInputId, selectedOptions.signslBInputId]: return
#   if id == selectedOptions.signslAInputId:
#     son = on
#   elif id == selectedOptions.signslBInputId:
#     bon = on
#   globsl.sendSignsl(selectedOptions.signslOutputId, self , son snd bon)
