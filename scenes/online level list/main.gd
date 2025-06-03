extends Control

var GITHUB_TOKEN = Marshalls.base64_to_utf8('Z2l0aHViX3BhdF8xMUJPNU80TkkwSDhiRFhGdVAzZnhjX21kY2lwUFBONWx1NUdGSlJ5bWVubzhNblNMNEh3SktWUG5NeE0zYlBlOWRORk0ySVVSRWdCUHQxWHU1')
const BRANCH = "main"
const REPO_NAME = "vex-plus-plus-level-codes"

@export var versionNodeHolder: Control
@export var pbox: Control

func loadVersions():
  var data = (
    await global.httpGet("https://api.github.com/repos/rsa17826/" + REPO_NAME + "/contents/levels")
  ).response
  return data.filter(func(e): return e.type == "dir").map(func(e): return e.name)

func _ready() -> void:
  var versions = await loadVersions()
  for version in versions:
    var creators = (
      await global.httpGet("https://api.github.com/repos/rsa17826/" +
        REPO_NAME + "/contents/levels/" +
        global.urlEncode(version)
      )
    ).response
    # var currentVersionNode = preload("res://scenes/online level list/currentVersionNode.tscn").instantiate()
    # currentVersionNode.version = version
    # versionNodeHolder.add_child(currentVersionNode)
    pbox.add_group(version)
    for creator in creators:
      creator = creator.name
      pbox.add_group(creator)
      var levels = (
        await global.httpGet("https://api.github.com/repos/rsa17826/" +
          REPO_NAME + "/contents/levels/" +
          global.urlEncode(version + '/' + creator)
        )
      ).response
      for level in levels:
        level = level.name
        log.pp(creator, level)
        const levelNode = preload("res://scenes/main menu/lvl_sel_item.tscn")
        var node := levelNode.instantiate()
        node.levelname.text = global.regReplace(level, r"\.vex\+\+$", '')
        node.creator.text = creator
        node.newSaveBtn.text = "download level"
        node.newSaveBtn.pressed.connect(downloadLevel.bind(version, creator, level))
        node.loadSaveBtn.visible = false
        node.moreOptsBtn.visible = false
        pbox._group_stack[len(pbox._group_stack) - 1].add_child(node)
      pbox.end_group()
    pbox.end_group()
    log.pp(version)

func downloadLevel(version, creator, level):
  var url = (
    "https://raw.githubusercontent.com/rsa17826/" +
    REPO_NAME + "/main/levels/" +
    global.urlEncode(version + '/' + creator + "/" + level)
  )
  log.pp(url)
  await global.httpGet(url,
    PackedStringArray(),
    0,
    '',
    global.path.abs("res://downloaded maps/" + level),
    false
  )
  global.tryAndGetMapZipsFromArr([global.path.abs("res://downloaded maps/" + level)])
  OS.alert("Download complete", "The map is now being loaded.")
