@icon("images/ghost.png")
extends EditorBlock
class_name BlockInnerLevel

@export var label: Node
@export var sprite: Node2D
var disabled := false

func enterLevel() -> void:
  if disabled: return
  await global.loadInnerLevel(selectedOptions.level)

func on_ready():
  onAllDataLoaded()

func onAllDataLoaded() -> void:
  disabled = false
  var text: String
  if not selectedOptions.level:
    text = "no level set"
    disabled = true
    setTexture(sprite, "config error")
  elif not global.file.isFile(global.path.join(global.levelFolderPath, selectedOptions.level + '.sds')):
    text = "invalid level\n" + selectedOptions.level
    disabled = true
    setTexture(sprite, "config error")
  elif selectedOptions.requiredLevelCount > len(global.beatLevels):
    text = "beat " + str(selectedOptions.requiredLevelCount - len(global.beatLevels)) + " more levels"
    disabled = true
    setTexture(sprite, "config error")
  elif selectedOptions.level in global.beatLevels.map(func(e: Dictionary) -> String:
    return e.name
    ):
    text = selectedOptions.level + "\nCOMPLETED"
    var idx = global.beatLevels.find_custom(func(e): return e.name == selectedOptions.level)
    var level = global.beatLevels[idx]
    if "star" not in level.blockSaveData:
      setTexture(sprite, "complete all stars collected")
    else:
      var stars: Array = level.blockSaveData.star
      var collected: int = 0
      var uncollected: int = 0
      for star in stars:
        if star.collected:
          collected += 1
        else:
          uncollected += 1
      text += "\n" + str(collected) + "/" + str(len(stars)) + " stars collected"

      if uncollected:
        setTexture(sprite, "complete not all stars collected")
      else:
        setTexture(sprite, "complete all stars collected")

  elif selectedOptions.level == global.currentLevel().name:
    text = "same as current level\n" + selectedOptions.level
    disabled = true
    setTexture(sprite, "config error")
  elif selectedOptions.level not in global.levelOpts.stages:
    text = "level settings not found\n" + selectedOptions.level
    disabled = true
    setTexture(sprite, "config error")
  elif selectedOptions.level in global.loadedLevels.map(func(e: Dictionary) -> String:
    return e.name
    ):
    text = "level already in path"
    disabled = true
    setTexture(sprite, "config error")
  else:
    # var starCount = 0
    # var data = await sds.loadDataFromFileSlow(global.path.abs(global.path.join("res://maps/", global.mainLevelName, selectedOptions.level + ".sds")))
    # for block in data.slice(1):
    #   if block.id == "star":
    #     starCount += 1
    # text = selectedOptions.level + "\nNEW\n0/" + str(starCount) + " stars collected"
    text = selectedOptions.level + "\nNEW\n0/??? stars collected"
  label.text = text

func generateBlockOpts():
  blockOptions.level = {"type": global.PromptTypes.string, "default": ""}
  blockOptions.requiredLevelCount = {"type": global.PromptTypes.int, "default": 0}
