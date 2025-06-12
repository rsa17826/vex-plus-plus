extends "res://scenes/blocks/editor.gd"

@export_group("INNER LEVEL")
@export var label: Node
@export var sprite: Node2D
var disabled := false

func enterLevel() -> void:
  if disabled: return
  global.loadInnerLevel(selectedOptions.level)

func on_ready() -> void:
  disabled = false
  var text: String = selectedOptions.level + "\nNEW"
  if not selectedOptions.level:
    text = "no level set"
    disabled = true
  elif not global.file.isFile(global.path.join(global.levelFolderPath, selectedOptions.level + '.sds')):
    text = "invalid level\n" + selectedOptions.level
    disabled = true
  elif selectedOptions.requiredLevelCount > len(global.beatLevels):
    text = "beat " + str(selectedOptions.requiredLevelCount - len(global.beatLevels)) + " more levels"
    disabled = true
  elif selectedOptions.level in global.beatLevels.map(func(e: Dictionary) -> String:
    return e.name
    ):
    disabled = true
    text = selectedOptions.level + "\nCOMPLETED"
  elif selectedOptions.level == global.currentLevel().name:
    text = "same as current level\n" + selectedOptions.level
    disabled = true
  elif selectedOptions.level not in global.levelOpts.stages:
    text = "level settings not found\n" + selectedOptions.level
    disabled = true
  elif selectedOptions.level in global.loadedLevels.map(func(e: Dictionary) -> String:
    return e.name
    ):
    text = "level already in path"
    disabled = true
  label.text = text

func generateBlockOpts():
  blockOptions.level = {"type": global.PromptTypes.string, "default": ""}
  blockOptions.requiredLevelCount = {"type": global.PromptTypes.int, "default": 0}
