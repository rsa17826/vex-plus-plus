@icon("images/1.png")
extends EditorBlock
class_name BlockShurikanGun

var cooldown := 0.0

func on_physics_process(delta: float) -> void:
  if cooldown <= 0:
    cooldown += selectedOptions.maxCooldown
    var s1 := spawnShurikan()
    var s2 := spawnShurikan()
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

func spawnShurikan() -> EditorBlock:
  var shurikan: EditorBlock = preload("res://scenes/blocks/bouncing shurikan/main.tscn").instantiate()
  shurikan.global_position = thingThatMoves.global_position
  shurikan.scale = startScale
  shurikan.DONT_SAVE = true
  shurikan.EDITOR_IGNORE = true
  shurikan.REMOVE_ON_RESPAWN = true
  shurikan.DONT_MOVE_ON_RESPAWN = true
  global.level.add_child(shurikan)
  return shurikan

func onSave() -> Array[String]:
  return ['cooldown']