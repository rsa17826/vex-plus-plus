extends HBoxContainer
var level: LevelServer.Level

@export var levelName: Label
@export var levelVersion: Label
@export var gameVersion: Label
@export var creatorName: Label
@export var creatorId: Control
@export var description: TextEdit
@export var viewOldVersions: Button
var levelList: Control
var oldVersionCount: int = 0

func showLevelData(levelToShow: LevelServer.Level) -> void:
  level = levelToShow
  if not level: return
  levelName.text = level.levelName
  creatorName.text = level.creatorName
  levelVersion.text = 'v' + str(level.levelVersion)
  gameVersion.text = 'game version: ' + str(level.gameVersion)
  description.text = level.description
  viewOldVersions.visible = !!oldVersionCount
  viewOldVersions.text = "view " + str(oldVersionCount) + " old versions"

func _on_download_pressed() -> void:
  LevelServer.downloadMap(level)

func _on_view_old_versions_pressed() -> void:
  var oldVersions = await LevelServer.loadOldVersions(level)
  levelList.loadLevelsFromArray(oldVersions)
