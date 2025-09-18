extends Control
var level: LevelServer.Level

@export var levelName: Control
@export var levelVersion: Control
@export var gameVersion: Control
@export var creatorName: Control
@export var creatorId: Control
@export var description: TextEdit
@export var viewOldVersions: Button
@export var levelImage: TextureRect
@export var dlInCorrectVersion: Button
@export var onlineButtonsContainer: Control
@export var offlineButtonsContainer: Control

var isOnline := true:
  set(val):
    onlineButtonsContainer.visible = val
    offlineButtonsContainer.visible = !val
    creatorId.visible = val
    isOnline = val

var levelList: Control
var search: Control

func _ready() -> void:
  dlInCorrectVersion.visible = global.launcherExists and global.VERSION != level.gameVersion

func showLevelData(levelToShow: LevelServer.Level) -> void:
  if level and global.isAlive(level):
    level.dataChanged.disconnect(levelDataChanged)
  levelToShow.dataChanged.connect(levelDataChanged)
  level = levelToShow
  levelDataChanged()

func levelDataChanged():
  if not level: return
  levelName.text = level.levelName
  creatorName.text = level.creatorName
  levelVersion.text = 'level version: ' + str(level.levelVersion)
  creatorId.text = str(level.creatorId)
  gameVersion.text = 'game version: ' + str(level.gameVersion)
  description.text = level.description
  viewOldVersions.visible = !!level.oldVersionCount
  viewOldVersions.text = "view " + str(level.oldVersionCount) + " old versions"
  if level.levelImage.get_size() in [Vector2i(292, 292), Vector2i(146, 146)]:
    levelImage.texture = ImageTexture.create_from_image(level.levelImage)
  elif level.levelImage.get_size():
    levelImage.texture = preload("res://scenes/blocks/image.png")

func _on_download_pressed() -> void:
  LevelServer.downloadMap(level)

func _on_view_old_versions_pressed() -> void:
  var oldVersions = await LevelServer.loadOldVersions(level)
  oldVersions.sort_custom(func(a, s):
    return a.levelVersion - s.levelVersion
  )
  levelList.loadLevelsFromArray(oldVersions, true)

func _on_download_and_play_pressed() -> void:
  if await LevelServer.downloadMap(level):
    global.loadMap(level.levelName, false)
func _on_download_and_play_2_pressed() -> void:
  if await LevelServer.downloadMap(level):
    global.openLevelInVersion(level.levelName, level.gameVersion)

func _on_creator_id_pressed() -> void:
  search.text += "/creatorId/=" + level.creatorId
  search.text = search.text.trim_prefix("/").replace("//", "/")

func _on_levelname_pressed() -> void:
  search.text += "/levelName/=" + level.levelName
  search.text = search.text.trim_prefix("/").replace("//", "/")

func _on_gameversiuon_pressed() -> void:
  search.text += "/gameVersion/=" + str(level.gameVersion)
  search.text = search.text.trim_prefix("/").replace("//", "/")

func _on_levelversions_pressed() -> void:
  search.text += "/levelVersion/=" + str(level.levelVersion)
  search.text = search.text.trim_prefix("/").replace("//", "/")

func _on_creatorname_pressed() -> void:
  search.text += "/creatorName/=" + level.creatorName
  search.text = search.text.trim_prefix("/").replace("//", "/")

func _on_copy_share_code_pressed() -> void:
  var levelCode = 'vex++:downloadMap/' + str(level.gameVersion) + '/' + str(level.onlineId) + '/' + global.urlEncode(level.levelName)
  DisplayServer.clipboard_set(levelCode)
  ToastParty.success("level code copied to clipboard")

func _on_new_save_pressed() -> void:
  global.loadMap(level.levelName, false)

func _on_load_save_pressed() -> void:
  global.loadMap(level.levelName, true)
