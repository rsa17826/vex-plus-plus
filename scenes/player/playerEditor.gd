@icon("res://scenes/player/images/anim/idle/1.png")

extends EditorBlock

@export var player: Player

func onEditorMove(moveDist: Vector2) -> void:
  if moveDist:
    player.lastSpawnPoint -= moveDist

func on_ready() -> void:
  id = 'player'

func onEditorMoveEnded():
  var saveData: Variant = sds.loadDataFromFile(global.path.abs("res://saves/saves.sds"), {})
  if global.mainLevelName in saveData:
    saveData[global.mainLevelName].lastSpawnPoint = player.lastSpawnPoint
    sds.saveDataToFile(global.path.abs("res://saves/saves.sds"), saveData)