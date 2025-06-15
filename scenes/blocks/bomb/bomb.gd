@icon("images/1.png")
extends EditorBlock
class_name BlockBomb

@export var blockDieArea: Area2D
@export var boomSprite: AnimatedSprite2D
@export var boomShape: CollisionShape2D

var exploded = false

func on_body_entered(body: Node):
  explode()

func on_respawn():
  if boomSprite.frame_changed.is_connected(onFrameChanged):
    boomSprite.frame_changed.disconnect(onFrameChanged)
  if boomSprite.animation_looped.is_connected(onAnimationLooped):
    boomSprite.animation_looped.disconnect(onAnimationLooped)
  exploded = false
  boomSprite.visible = false
  boomSprite.stop()

func onAnimationLooped():
  boomSprite.visible = false
  boomSprite.stop()
  __disable.call_deferred()

func onFrameChanged():
  match boomSprite.frame:
    1:
      boomShape.shape.radius = 605.67
    4:
      boomShape.shape.radius = 897.05
    6:
      boomShape.shape.radius = 1024.0

  log.pp(boomSprite.frame, boomShape.shape.radius)
  for block in (
    blockDieArea.get_overlapping_bodies()
    + blockDieArea.get_overlapping_areas()
  ):
    if block is Player:
      block.die.call_deferred()
    else:
      block.root.__disable.call_deferred()

func explode():
  if exploded: return
  exploded = true
  $CharacterBody2D/Sprite2D.visible = false
  boomSprite.visible = true
  boomSprite.play("explode")
  boomShape.shape.radius = 206.06
  boomSprite.frame_changed.connect(onFrameChanged)
  boomSprite.animation_looped.connect(onAnimationLooped)
