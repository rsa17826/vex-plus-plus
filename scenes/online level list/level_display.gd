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
@export var large: Array[Control]

func matches(new_text):
  if not new_text:
    return true
  var textArr = new_text.split("/")
  for i in range(0, floor(len(textArr) / 2.0) * 2, 2):
    var key = textArr[i]
    if not textArr[i + 1]: continue
    var type = textArr[i + 1][0]
    var val = textArr[i + 1].trim_prefix(type)
    match type:
      '=':
        if !(level[key] == val):
          return false
      '~':
        if !(level[key] in (val)):
          return false
      '>':
        if !(level[key] > float(val)):
          return false
      '<':
        if !(level[key] < float(val)):
          return false
      _:
        if !(((type + val).to_lower()) in str(level[key]).to_lower()):
          return false
  return true

func filter(new_text):
  visible = matches(new_text)

var isOnline := true:
  set(val):
    isOnline = val
    updateOnlineState()

func updateOnlineState():
  onlineButtonsContainer.visible = isOnline
  offlineButtonsContainer.visible = !isOnline
  creatorId.visible = isOnline
  for thing in large:
    thing.visible = true
  if (global.useropts.smallLevelDisplaysInOnlineLevelList and isOnline) \
  or (global.useropts.smallLevelDisplaysInLocalLevelList and !isOnline):
    for thing in large:
      thing.visible = false

var levelList: Control
var search: Control

func _ready() -> void:
  dlInCorrectVersion.visible = global.launcherExists and global.VERSION != level.gameVersion
  updateOnlineState()

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

func _on_duplicate_pressed() -> void:
  OS.move_to_trash(global.path.join(global.MAP_FOLDER, level.levelName + " (copy)"))
  global.copyDir(
    global.path.join(global.MAP_FOLDER, level.levelName),
    global.path.join(global.MAP_FOLDER, level.levelName + " (copy)")
  )
  global.mainMenu.loadLocalLevelList()

func _on_delete_pressed() -> void:
  OS.move_to_trash(global.path.join(global.MAP_FOLDER, level.levelName))
  global.mainMenu.loadLocalLevelList()

func _on_rename_pressed() -> void:
  var newName = (await global.prompt(
    "Rename map",
    global.PromptTypes.string,
    level.levelName
  )).replace("/", '').replace("\\", '')
  DirAccess.rename_absolute(
    global.path.join(global.MAP_FOLDER, level.levelName),
    global.path.join(global.MAP_FOLDER,
      newName
    )
  )
  var saveData: Dictionary = sds.loadDataFromFile(global.getLevelSavePath(level.levelName), {})
  if level.levelName in saveData:
    saveData[newName] = saveData[level.levelName]
    saveData.erase(level.levelName)
    sds.saveDataToFile(global.getLevelSavePath(newName), saveData)
    OS.move_to_trash(global.getLevelSavePath(level.levelName))
  global.mainMenu.loadLocalLevelList()

func _on_export_pressed() -> void:
  if FileAccess.file_exists(global.path.abs("res://exports/" + level.levelName + ".vex++")):
    OS.move_to_trash(global.path.abs("res://exports/" + level.levelName + ".vex++"))
    await global.wait(100)
  global.zipDir(
    global.path.join(global.MAP_FOLDER, level.levelName),
    global.path.abs("res://exports/" + level.levelName + ".vex++")
  )
  ToastParty.info("map exported successfully")
  if global.useropts.openExportsDirectoryOnExport:
    OS.shell_open(global.path.abs("res://exports"))

func _on_upload_pressed() -> void:
  if not LevelServer.user:
    global.mainMenu._on_show_login_pressed()
    await global.waituntil(func():
      return !global.mainMenu.loginMenuBg.visible)
    if not LevelServer.user:
      ToastParty.err("you must login to upload maps")
      return
  if !FileAccess.file_exists(global.path.join(global.MAP_FOLDER, level.levelName, "/image.png")):
    ToastParty.err("the map must have an image - an image is created by saving the map!")
    return
  var outpath = global.path.abs("res://exports/" + level.levelName + ".vex++")
  global.zipDir(
    global.path.join(global.MAP_FOLDER, level.levelName),
    outpath
  )
  var f = FileAccess.open(outpath, FileAccess.READ)
  # var c = Marshalls.raw_to_base64(f.get_buffer(f.get_length()))
  var c = f.get_buffer(f.get_length())
  if not level.creatorName:
    ToastParty.err("Please enter an creatorName name")
    return
  if not level.levelName:
    ToastParty.err("Please enter a map name")
    return
  global.mainMenu.get_node("AnimatedSprite2D").visible = true
  var img = Image.new()
  img.load(global.path.join(global.MAP_FOLDER, level.levelName, "/image.png"))
  if img.get_size() != Vector2i(292, 292):
    ToastParty.err("the map must have an image of a valid size - a valid image is created by saving the map!")
    return
  f.close()
  if await LevelServer.uploadLevel(
    LevelServer.Level.new(
      level.levelName,
      - 1,
      level.description,
      '',
      level.creatorName,
      level.gameVersion,
      level.levelVersion,
      c,
      img
    )
  ):
    ToastParty.success("Level uploaded!")
  global.mainMenu.get_node("AnimatedSprite2D").visible = false

func _on_more_pressed() -> void:
  global.mainMenu.showMoreOptions(level)
