@icon("res://scenes/player/images/anim/idle/1.png")

extends EditorBlock
class_name EditorPlayer

@export var player: Player
## the first player, the one the level's start position and the camera default belong to
@export var isPrimary := true

func onEditorMove(moveDist: Vector2) -> void:
  if moveDist:
    player.lastSpawnPoint -= moveDist

func on_ready() -> void:
  id = 'player' if isPrimary else 'extra player'

func onEditorMoveEnded():
  var saveData: Variant = sds.loadDataFromFile(global.CURRENT_LEVEL_SAVE_PATH, {})
  if global.mainLevelName in saveData:
    saveData[global.mainLevelName].players[player.playerIndex].lastSpawnPoint = player.lastSpawnPoint
    sds.saveDataToFile(global.CURRENT_LEVEL_SAVE_PATH, saveData)
