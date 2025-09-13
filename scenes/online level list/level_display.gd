extends HBoxContainer
var level: LevelServer.Level

@export var levelName: Control
@export var levelVersion: Control
@export var gameVersion: Control
@export var creatorName: Control
@export var creatorId: Control
@export var description: TextEdit
@export var viewOldVersions: Button
@export var levelImage: TextureRect
var levelList: Control
var search: Control

func showLevelData(levelToShow: LevelServer.Level) -> void:
  level = levelToShow
  if not level: return
  levelName.text = level.levelName
  creatorName.text = level.creatorName
  levelVersion.text = 'v' + str(level.levelVersion)
  creatorId.text = str(level.creatorId)
  gameVersion.text = 'game version: ' + str(level.gameVersion)
  description.text = level.description
  viewOldVersions.visible = !!level.oldVersionCount
  viewOldVersions.text = "view " + str(level.oldVersionCount) + " old versions"
  if level.levelImage.get_size() in [Vector2i(292, 292), Vector2i(146, 146)]:
    levelImage.texture = ImageTexture.create_from_image(level.levelImage)

func _on_download_pressed() -> void:
  LevelServer.downloadMap(level)

func _on_view_old_versions_pressed() -> void:
  var oldVersions = await LevelServer.loadOldVersions(level)
  oldVersions.sort_custom(func(a, s):
    return a.levelVersion - s.levelVersion
  )
  levelList.loadLevelsFromArray(oldVersions)

func _on_download_and_play_pressed() -> void:
  if await LevelServer.downloadMap(level):
    global.loadMap(level.levelName, false)

func _on_creator_id_pressed() -> void:
  search.text += "/creatorId/=" + level.creatorId
  search.text = search.text.trim_prefix("/")

func _on_levelname_pressed() -> void:
  search.text += "/levelName/=" + level.levelName
  search.text = search.text.trim_prefix("/")

func _on_gameversiuon_pressed() -> void:
  search.text += "/gameVersion/=" + str(level.gameVersion)
  search.text = search.text.trim_prefix("/")

func _on_levelversions_pressed() -> void:
  search.text += "/levelVersion/=" + str(level.levelVersion)
  search.text = search.text.trim_prefix("/")

func _on_creatorname_pressed() -> void:
  search.text += "/creatorName/=" + level.creatorName
  search.text = search.text.trim_prefix("/")
