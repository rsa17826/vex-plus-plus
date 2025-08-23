extends Control

func _ready() -> void:
  global.useropts.theme = 1
  await global.wait()
  global.fullscreen(-1)
  # generate settings
  var text = '## Settings\n'
  var data = global.file.read("res://scenes/main menu/userOptsMenu.jsonc")
  var oldmd = global.file.read("res://readme.md", false)
  for thing in data:
    match thing.thing:
      "option":
        log.pp(thing)
        break
      "group":
        text += '\n### ' + (thing.name)
        # log.pp(thing.name, thing.value)
        for a in thing.value:
          if 'editorOnly' in a and a.editorOnly: continue
          var keyVal = '- **' + a.key + '**: '
          text += '\n\n' + keyVal
          var lastText = ''
          if keyVal in oldmd:
            lastText = oldmd.split(keyVal)[1].split("\n")[0]
          if lastText:
            text += lastText
            continue
          else:
            DisplayServer.clipboard_set(keyVal)
            text += await getinfo("setting: " + a.key)
  # generate blocks
  text += '\n\n\n## Blocks\n'
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
      DisplayServer.clipboard_set(keyVal)
      text += await getinfo("block: " + id + '\n"' + keyVal + '"')
    text += '\n'
    for k in ['EDITOR_OPTION_scale', 'EDITOR_OPTION_rotate', 'canAttachToThings', 'canAttachToPaths']:
      text += "\n  - " + k.replace("EDITOR_OPTION_", '') if block[k] else ""
    if block.blockOptions:
      text += "\n\n  - **settings**:"
      for k in block.blockOptions:
        var innerKeyVal = '    - **' + k + '**: '
        var innerLastText = ''
        if lastText:
          innerLastText = ''
          if innerKeyVal in oldmd:
            innerLastText = oldmd.split(innerKeyVal)[1].split("\n")[0]
          # var innerOldMd = oldmd.split(keyVal)[1].split("\n\n- **")[0]
          # if innerKeyVal in innerOldMd:
          #   innerLastText = innerOldMd.split(innerKeyVal)[1].split("\n")[0]
          log.pp(innerLastText, "innerLastText")
        if !innerLastText:
          DisplayServer.clipboard_set(innerKeyVal)
          innerLastText = await getinfo("block: " + id + '\n"' + innerKeyVal + '"')
        text += "\n" + innerKeyVal + innerLastText
    block.queue_free()
  # text+="- **input detector**"
  # log.pp(text)
  global.file.write("res://test.md", text, false)
  get_tree().quit()

func getinfo(text):
  return "asdkasdkjllkjdas"
  return await global.prompt(text, global.PromptTypes.string)