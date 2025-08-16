extends EditorBlock

@export var player: Player

func onEditorMove(moveDist: Vector2) -> void:
  if moveDist:
    player.lastSpawnPoint -= moveDist

func onEditorMoveEnded():
  var saveData: Variant = sds.loadDataFromFile(global.path.abs("res://saves/saves.sds"), {})
  saveData[global.mainLevelName].lastSpawnPoint = player.lastSpawnPoint
  sds.saveDataToFile(global.path.abs("res://saves/saves.sds"), saveData)