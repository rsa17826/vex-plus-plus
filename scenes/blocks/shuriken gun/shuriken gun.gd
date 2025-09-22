@icon("images/1.png")
extends EditorBlock
class_name BlockShurikenGun

var cooldown := 0.0

func on_physics_process(delta: float) -> void:
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
    thingThatMoves.scale = Vector2(1,1)
  if cooldown > 0:
    cooldown -= delta

func on_respawn():
  if loadDefaultData:
    cooldown = .8

func generateBlockOpts():
  blockOptions.maxCooldown = {"default": 100, "type": global.PromptTypes.float}

func spawnShuriken() -> EditorBlock:
  var shuriken: EditorBlock = preload("res://scenes/blocks/bouncing shuriken/main.tscn").instantiate()
  shuriken.global_position = thingThatMoves.global_position
  shuriken.scale = startScale
  shuriken.DONT_SAVE = true
  shuriken.EDITOR_IGNORE = true
  shuriken.REMOVE_ON_RESPAWN = true
  shuriken.DONT_MOVE_ON_RESPAWN = true
  global.level.add_child(shuriken)
  return shuriken

func onSave() -> Array[String]:
  return ['cooldown']