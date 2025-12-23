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
  exploded = true
  boomSprite.stop()
  boomSprite.visible = false
  if boomSprite.frame_changed.is_connected(onFrameChanged):
    boomSprite.frame_changed.disconnect(onFrameChanged)
  if boomSprite.animation_looped.is_connected(onAnimationLooped):
    boomSprite.animation_looped.disconnect(onAnimationLooped)
  await global.wait()
  boomSprite.visible = false
  if boomSprite.frame_changed.is_connected(onFrameChanged):
    boomSprite.frame_changed.disconnect(onFrameChanged)
  if boomSprite.animation_looped.is_connected(onAnimationLooped):
    boomSprite.animation_looped.disconnect(onAnimationLooped)
  boomSprite.stop()
  boomSprite.visible = false
  $CharacterBody2D.collsiionOn_top = []
  $CharacterBody2D.collsiionOn_bottom = []
  $CharacterBody2D.collsiionOn_left = []
  $CharacterBody2D.collsiionOn_right = []
  exploded = false

func onAnimationLooped():
  boomSprite.visible = false
  boomSprite.stop()
  __disable.call_deferred()

func onFrameChanged():
  if respawning: return
  match boomSprite.frame:
    1:
      boomShape.shape.radius = 605.67
    4:
      boomShape.shape.radius = 897.05
    6:
      boomShape.shape.radius = 1024.0
    8:
      boomShape.shape.radius = 10

  for block in (
    blockDieArea.get_overlapping_bodies()
    + blockDieArea.get_overlapping_areas()
  ):
    if block is Player:
      await global.wait()
      deathEnter(block)
    else:
      block = block.root
      if block == self: continue
      if block is BlockBomb:
        block.explode()
      else:
        # block.hasBeenExploded = true
        block.__disable.call_deferred()

func explode():
  if exploded: return
  exploded = true
  $CharacterBody2D/Sprite2D.visible = false
  boomSprite.visible = true
  boomShape.set_deferred("shape", CircleShape2D.new())
  await global.wait()
  boomShape.shape.radius = 206.06
  boomSprite.frame_changed.connect(onFrameChanged)
  boomSprite.animation_looped.connect(onAnimationLooped)
  boomSprite.play("explode")

func onSave() -> Array[String]:
  return ["thingThatMoves.global_position", "thingThatMoves.vel"]

func getDeathMessage(message: String, dir: Vector2) -> String:
  if boomSprite.frame <= 2:
    message += "got exploded"
  else:
    match dir:
      Vector2.UP:
        message += "jumped into an active explosion"
      Vector2.DOWN:
        message += "fell into an active explosion"
      Vector2.LEFT, Vector2.RIGHT:
        message += "walked into an explosion"
      Vector2.ZERO:
        message += "got exploded"
  return message