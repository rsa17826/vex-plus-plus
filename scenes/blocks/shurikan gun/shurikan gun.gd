@icon("images/1.png")
extends EditorBlock
class_name BlockShurikanGun

var cooldown := 0.0

func on_physics_process(delta: float) -> void:
  if cooldown <= 0:
    var s1 := spawnShurikan()
    s1.position += Vector2(-50, 50)

func on_process(delta):
  if cooldown > 0:
    cooldown -= delta

func on_respawn():
  cooldown = 0

func generateBlockOpts():
  blockOptions.maxCooldown = {"default": 100, "type": global.PromptTypes.float}

func spawnShurikan() -> EditorBlock:
  var shurikan: EditorBlock = preload("res://scenes/blocks/bouncing shurikan/main.tscn").instantiate()
  shurikan.global_position = thingThatMoves.global_position
  shurikan.rotation = thingThatMoves.rotation
  cooldown = selectedOptions.maxCooldown
  shurikan.scale = startScale
  shurikan.DONT_SAVE = true
  # shurikan.EDITOR_IGNORE = true
  global.level.add_child(shurikan)
  return shurikan