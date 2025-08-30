extends Control
var fs = false

func _ready() -> void:
  global.useropts.theme = 1
  await global.wait()
  # generate settings
  var text = ''
  var oldmd = global.file.read("res://readme.md", false)

  text += "## Controls\n"
  for action in InputMap.get_actions():
    if action.begins_with("ui_"): continue
    if action.begins_with("CREATE NEW - "): continue
    var keyVal = "\n- **" + action + "**: "
    text += keyVal
    var lastText = ''
    if keyVal in oldmd:
      lastText = oldmd.split(keyVal)[1].split("\n")[0]
    if lastText:
      text += lastText
      continue
    else:
      # DisplayServer.clipboard_set(keyVal)
      text += await getinfo("keybind: " + action)
  text += '\n- **"CREATE NEW - _block name_"**: creates a new instance of _block name_ the same is if it was picked from the editor bar.'
  text += '\n\n## Settings'
  var data = global.file.read("res://scenes/main menu/userOptsMenu.jsonc")
  for thing in data:
    match thing.thing:
      "option":
        log.pp(thing)
        break
      "group":
        text += '\n\n### ' + (thing.name) + '\n'
        # log.pp(thing.name, thing.value)
        for a in thing.value:
          if 'editorOnly' in a and a.editorOnly: continue
          var keyVal = '- **' + a.key + '**: '
          text += '\n' + keyVal
          var lastText = ''
          if keyVal in oldmd:
            lastText = oldmd.split(keyVal)[1].split("\n")[0]
          if lastText:
            text += lastText
            continue
          else:
            # DisplayServer.clipboard_set(keyVal)
            text += await getinfo("setting: " + a.key)
  # generate blocks
  var setKeys = {}
  text += '\n\n## Blocks'
  for id in global.DEFAULT_BLOCK_LIST:
    var block = load("res://scenes/blocks/" + id + "/main.tscn").instantiate()
    add_child(block)
    await global.wait()
    # log.pp(id, block)
    var keyVal = '- **' + id + '**: '
    text += "\n\n" + keyVal
    var lastText = ''
    if keyVal in oldmd:
      lastText = oldmd.split(keyVal)[1].split("\n")[0]
    if lastText:
      text += lastText
    else:
      # DisplayServer.clipboard_set(keyVal)
      text += await getinfo("block: " + id + '\n"' + keyVal + '"')
    var imageLocations = [
      "editorBar.png",
      "1.png",
      "pressed.png",
      "ghost.png",
      "base/1.png",
    ]
    var imageLocation = imageLocations[
      imageLocations.find_custom(func(e):
        return ResourceLoader.exists("res://scenes/blocks/" + id + "/images/" + e))
    ]
    # text += "\n ![" + id + "](" + "scenes/blocks/" + id + "/images/" + imageLocation + '){width=10 height=10}'
    var scale = Vector2(1, 1)
    var image = load("res://scenes/blocks/" + id + "/images/" + imageLocation)
    var origSize = image.get_size() * scale
    var maxSize = max(origSize.x, origSize.y)
    var scaleFactor = max(scale.x, scale.y) * (50 / maxSize)
    # scale = Vector2(
    #   scaleFactor,
    #   scaleFactor
    # )
    text += '\n  <img src="' + "scenes/blocks/" + id + "/images/" + imageLocation + '" alt="image of block ' + id + '" width="' + str(int(origSize.x * scaleFactor)) + '" height="' + str(int(origSize.y * scaleFactor)) + '">'
    text += '\n'
    for k in ['EDITOR_OPTION_scale', 'EDITOR_OPTION_rotate', 'canAttachToThings', 'canAttachToPaths']:
      if block[k]:
        text += "\n  - " + k \
        .replace("EDITOR_OPTION_scale", 'scalable') \
        .replace("EDITOR_OPTION_rotate", 'rotatable')
    if block.blockOptions:
      text += "\n  - **settings**:"
      for k in block.blockOptions:
        var innerKeyVal = '    - **' + k + '**: '
        var innerLastText = ''
        if k in setKeys:
          innerLastText += setKeys[k]
          # lastText = ''
        if lastText:
          innerLastText = ''
          if innerKeyVal in oldmd:
            innerLastText = oldmd.split(innerKeyVal)[1].split("\n")[0]
          # var innerOldMd = oldmd.split(keyVal)[1].split("\n\n- **")[0]
          # if innerKeyVal in innerOldMd:
          #   innerLastText = innerOldMd.split(innerKeyVal)[1].split("\n")[0]
          # log.pp(innerLastText, "innerLastText")
        if !innerLastText:
          # DisplayServer.clipboard_set(innerKeyVal)
          innerLastText = await getinfo("block setting: " + id + '\n"' + innerKeyVal + '"')
        setKeys[k] = innerLastText
        text += "\n" + innerKeyVal + innerLastText
        if global.same(block.blockOptions[k].type, global.PromptTypes._enum):
          var values = block.blockOptions[k].values
          for enumKey in values:
            var enumKeyVal = "      - **" + enumKey + "**"
            innerLastText = ''
            if enumKeyVal in oldmd:
              innerLastText = oldmd.split(enumKeyVal)[1].split("\n")[0]
            if not innerLastText:
              innerLastText = await getinfo("block setting: " + id + '\n"' + innerKeyVal + enumKey + '"')
            text += "\n" + enumKeyVal + innerLastText
    block.queue_free()
  # log.pp(text)
  var setKeysString = "<!--"
  for k in setKeys:
    setKeysString += "\n    - **" + k + "**: " + setKeys[k]
  setKeysString += "\n-->"
  global.file.write(
    "res://readme.md",
    global.regReplace(
      oldmd,
      "(<!-- start auto -->)[\\s\\S]+(<!-- end auto -->)",
      "$1\n" +
      setKeysString
      + "\n\n" + text + "\n\n$2"
    ),
    false
  )
  get_tree().quit()

func getinfo(text):
  if not fs:
    global.fullscreen(-1)
    fs = true
  # return "asdkasdkjllkjdas"
  return await global.prompt(text, global.PromptTypes.string)