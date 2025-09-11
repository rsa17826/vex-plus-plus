extends Control

var GITHUB_TOKEN = global.getToken()

@export var loadingText: Label
@export var levelListContainerNode: Control

# func loadVersions():
#   var data = (
#     await global.httpGet("https://api.github.com/repos/rsa17826/" + global.REPO_NAME + "/contents/levels")
#   ).response
#   return data.filter(func(e): return e.type == "dir").map(func(e): return e.name)

# func _ready() -> void:
#   var versions = await loadVersions()
#   for version in versions:
#     var creators = (
#       await global.httpGet("https://api.github.com/repos/rsa17826/" +
#         global.REPO_NAME + "/contents/levels/" +
#         global.urlEncode(version)
#       )
#     ).response
#     # var currentVersionNode = preload("res://scenes/online level list/currentVersionNode.tscn").instantiate()
#     # currentVersionNode.version = version
#     # versionNodeHolder.add_child(currentVersionNode)
#     pbox.add_group(version)
#     for creator in creators:
#       creator = creator.name
#       pbox.add_group(creator)
#       var levels = (
#         await global.httpGet("https://api.github.com/repos/rsa17826/" +
#           global.REPO_NAME + "/contents/levels/" +
#           global.urlEncode(version + '/' + creator)
#         )
#       ).response
#       for level in levels:
#         level = level.name
#         log.pp(creator, level)
#         const levelNode = preload("res://scenes/main menu/lvl_sel_item.tscn")
#         var node := levelNode.instantiate()
#         node.levelname.text = global.regReplace(level, r"\.vex\+\+$", '')
#         node.creator.text = creator
#         node.newSaveBtn.text = "download level"
#         node.newSaveBtn.pressed.connect(global.downloadMap.bind(version, creator, level))
#         node.loadSaveBtn.visible = false
#         node.moreOptsBtn.visible = false
#         pbox._group_stack[len(pbox._group_stack) - 1].add_child(node)
#       pbox.end_group()
#     pbox.end_group()
#     log.pp(version)
# [
#   {
#     "name": "main",
#     "commit": {
#       "sha": "e40933334b0b03365da81d17f17bbc117f316b8c",
#       "url": "https://api.github.com/repos/rsa17826/vex-plus-plus-level-codes/commits/e40933334b0b03365da81d17f17bbc117f316b8c"
#     },
#     "protected": false
#   }
# ]
#
# https://api.github.com/repos/rsa17826/vex-plus-plus-level-codes/git/trees/e8ce6f3c20559ef736e5ab289d15002a5fe2aa6f?recursive=1

func _ready() -> void:
  if global.useropts.loadOnlineLevelListOnSceneLoad:
    loadOnlineLevels()

func loadOnlineLevels():
  $AnimatedSprite2D.visible = true
  $AnimatedSprite2D.frame = 0
  loadingText.text = "Loading..."
  loadingText.visible = true
  var data: Array = await LevelServer.loadAllLevels()
  # var branches = (await global.httpGet("https://api.github.com/repos/rsa17826/" + global.REPO_NAME + "/branches" + '?rand=' + str(randf()))).response
  # var sha = ""
  # for branch in branches:
  #   if branch.name != global.BRANCH: continue
  #   sha = branch.commit.sha
  #   break
  # if not sha:
  #   log.err("Could not find branch")
  #   return
  # var url = (
  #   "https://api.github.com/repos/rsa17826/" +
  #   global.REPO_NAME + "/git/trees/" + sha +
  #   "?recursive=1" + '&rand=' + str(randf())
  # )
  # log.pp(url)
  # var levels = (await global.httpGet(
  #   url
  # )).response
  # var allData := {}
  # for level in levels.tree:
  #   var data = global.regMatch(level.path, r"^levels/(\d+)/([^/]+)/([^/]+\.vex\+\+)$")
  #   if not data:
  #     # log.err(level.path)
  #     continue
  #   var version = int(data[1])
  #   var creator = data[2]
  #   var levelname = data[3]
  #   if version not in allData:
  #     allData[version] = {}
  #   if creator not in allData[version]:
  #     allData[version][creator] = []
  #   allData[version][creator].append(levelname)
  var allData := {}
  for level in data:
    var gameVersion = int(level.gameVersion)
    var creatorName = level.creatorName
    # var levelVersion = level.levelVersion
    # var levelData = level.levelData
    var levelname = level.name
    if gameVersion not in allData:
      allData[gameVersion] = {}
    if creatorName not in allData[gameVersion]:
      allData[gameVersion][creatorName] = []
    allData[gameVersion][creatorName].append(levelname)

  log.pp(allData)
  var loadedLevelCount = 0
  var levelsForCurrentVersionCount = 0
  for child in levelListContainerNode.get_children():
    child.queue_free()
  var arr := allData.keys()
  arr.sort()
  arr.reverse()
  const versionNode := preload("res://scenes/online level list/version.tscn")
  const creatorNode := preload("res://scenes/online level list/creator.tscn")
  const levelNode := preload("res://scenes/online level list/level.tscn")
  for version in arr:
    if version != global.VERSION and global.useropts.onlyShowLevelsForCurrentVersion: continue
    var v = versionNode.instantiate()
    v.title = str(version)
    v.folded = false if global.useropts.autoExpandAllGroupsInOnlineLevelList else version != global.VERSION
    v.thisText = str(version).to_lower().replace('\n', '')
    levelListContainerNode.add_child(v)
    for creator in allData[version]:
      var c = creatorNode.instantiate()
      c.title = creator
      c.thisText = creator.to_lower().replace('\n', '')
      v.get_node("VBoxContainer").add_child(c)
      for level in allData[version][creator]:
        if version == global.VERSION:
          levelsForCurrentVersionCount += 1
        loadedLevelCount += 1
        var l = levelNode.instantiate()
        onTextChanged.connect(func(text): otc.call(text, v), ConnectFlags.CONNECT_DEFERRED)
        l.levelname.text = global.regReplace(level, r"\.vex\+\+$", '')
        l.thisText = l.levelname.text.to_lower().replace('\n', '')
        l.downloadBtn.pressed.connect(global.downloadMap.bind(version, creator, level))
        c.get_node("VBoxContainer").add_child(l)

  if global.useropts.onlyShowLevelsForCurrentVersion:
    loadingText.text = 'Loaded levels: ' + str(loadedLevelCount)
  else:
    loadingText.text = 'Loaded levels: ' + str(levelsForCurrentVersionCount) + " / " + str(loadedLevelCount)
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
func _on_search_text_changed(new_text: String) -> void:
  onTextChanged.emit(new_text)
