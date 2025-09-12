extends Control

var GITHUB_TOKEN = global.getToken()

@export var loadingText: Label
@export var levelListContainerNode: Control

func _ready() -> void:
  if global.useropts.loadOnlineLevelListOnSceneLoad:
    loadOnlineLevels()

func loadLevelsFromArray(data: Array) -> void:
  var loadedLevelCount = 0
  var levelsForCurrentVersionCount = 0
  for child in levelListContainerNode.get_children():
    child.queue_free()
  const levelNode := preload("res://scenes/online level list/level display.tscn")
  for level in data:
    loadedLevelCount += 1
    if level.gameVersion != global.VERSION and global.useropts.onlyShowLevelsForCurrentVersion: continue
    if level.gameVersion == global.VERSION:
      levelsForCurrentVersionCount += 1
    var node = levelNode.instantiate()
    node.levelList = self
    node.showLevelData(level)
    log.pp('level', level)
    levelListContainerNode.add_child(node)
  if global.useropts.onlyShowLevelsForCurrentVersion:
    loadingText.text = 'Loaded levels: ' + str(loadedLevelCount)
  else:
    loadingText.text = 'Loaded levels: ' + str(levelsForCurrentVersionCount) + " / " + str(loadedLevelCount)

func loadOnlineLevels():
  $AnimatedSprite2D.visible = true
  $AnimatedSprite2D.frame = 0
  loadingText.text = "Loading..."
  loadingText.visible = true
  var data: Array = await LevelServer.loadAllLevels()
  var loadedLevelData = {}
  var newData = []
  for level: LevelServer.Level in data:
    var oldVersionCount = 0
    if not (level.creatorId in loadedLevelData):
      loadedLevelData[level.creatorId] = {}
    if level.levelName in loadedLevelData[level.creatorId]:
      if level.levelVersion < loadedLevelData[level.creatorId][level.levelName].levelVersion: continue
      else:
        oldVersionCount = loadedLevelData[level.creatorId][level.levelName].oldVersionCount + 1
        newData.erase(loadedLevelData[level.creatorId][level.levelName])
    level.oldVersionCount = oldVersionCount
    loadedLevelData[level.creatorId][level.levelName] = level
    newData.append(level)

  log.pp(loadedLevelData, newData)
  loadLevelsFromArray(newData)
  $AnimatedSprite2D.visible = false

func otc(text: String, version: NestedSearchable):
  if not version: return
  version.updateSearch(text)

func loadLevelById() -> void:
  var data: String = (
    await global.prompt(
      "Enter the ID of the level you want to load",
      global.PromptTypes.string,
      "",
      "",
    )
  ).split("/")
  data = data.trim_prefix("vex++:downloadMap/")
  if len(data) != 3:
    ToastParty.error("Invalid input")
    return
  if !data[2].ends_with(".vex++"): data[2] += ".vex++"
  global.downloadMap(data[0], data[1], data[2])

func loadMenu() -> void:
  get_tree().change_scene_to_file.call_deferred("res://scenes/main menu/main_menu.tscn")

signal onTextChanged
func _on_search_text_submitted(new_text: String) -> void:
  log.pp("asdasd", new_text)

func _on_filter_text_changed(new_text: String) -> void:
  onTextChanged.emit(new_text)
