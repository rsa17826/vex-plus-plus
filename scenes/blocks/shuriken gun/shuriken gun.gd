@icon("images/1.png")
extends EditorBlock
class_name BlockShurikenGun

var cooldown := 0.0

var activeShurikens: Array[BlockBouncingShurikan]:
  get():
    activeShurikens.assign(activeShurikens.filter(global.isAlive))
    return activeShurikens

func on_physics_process(delta: float) -> void:
  if selectedOptions.killAfterDistance:
    # log.err(111111, selectedOptions.killAfterDistance)
    for s in activeShurikens:
      if s.thingThatMoves.global_position.distance_to(global_position) > selectedOptions.killAfterDistance:
        s.queue_free()

  if cooldown <= 0:
    cooldown += selectedOptions.maxCooldown
    var s1 := spawnShuriken()
    var s2 := spawnShuriken()
    var offset = Vector2(-50, 50) * thingThatMoves.global_scale
    var dir = Vector2(-1, 1)
    s1.position += offset.rotated(thingThatMoves.global_rotation)
    s1.thingThatMoves.dir = dir.rotated(thingThatMoves.global_rotation)
    offset.x *= -1
    dir.x *= -1
    s2.position += offset.rotated(thingThatMoves.global_rotation)
    s2.thingThatMoves.dir = dir.rotated(thingThatMoves.global_rotation)
    activeShurikens.append(s1)
    activeShurikens.append(s2)

func on_process(delta):
  var totalTime = .8
  if cooldown < totalTime:
    thingThatMoves.scale = global.animate(1, [
      {
        "from": startScale,
        "to": startScale * 1.3,
        "until": .7,
      },
      {
        "from": startScale * 1.3,
        "to": startScale,
        "until": .8,
      }
    ], totalTime - (cooldown)) * 7
  else:
    thingThatMoves.scale = Vector2(1, 1)
  if cooldown > 0:
    if cooldown < .1:
      if selectedOptions.maxCount and len(activeShurikens) >= selectedOptions.maxCount: return
    cooldown -= delta

func on_respawn():
  for s in activeShurikens:
    s.queue_free()
  activeShurikens.assign([])
  if loadDefaultData:
    cooldown = .8

func generateBlockOpts():
  blockOptions.maxCooldown = {"default": 7.0, "type": global.PromptTypes.float, "suffix": "s"}
  blockOptions.maxCount = {"default": 0, "type": global.PromptTypes.int}
  blockOptions.killAfterDistance = {"default": 0.0, "type": global.PromptTypes.float}
  blockOptions.killAfterTime = {"default": 0.0, "type": global.PromptTypes.float, "suffix": "s"}

func spawnShuriken() -> EditorBlock:
  var shuriken: EditorBlock = preload("res://scenes/blocks/bouncing shuriken/main.tscn").instantiate()
  shuriken.global_position = thingThatMoves.global_position
  shuriken.scale = startScale
  shuriken.id = "bouncing shuriken"
  shuriken.DONT_SAVE = true
  shuriken.EDITOR_IGNORE = true
  shuriken.REMOVE_ON_RESPAWN = true
  shuriken.DONT_MOVE_ON_RESPAWN = true
  shuriken.KILL_AFTER_TIME = selectedOptions.killAfterTime
  global.level.add_child(shuriken)
  return shuriken

func onSave() -> Array[String]:
  return ['cooldown']
