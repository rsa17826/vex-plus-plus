extends Control

func _ready() -> void:
  await global.wait()
  global.fullscreen(-1)
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
          if 'editorOnly' in a and a.editorOnly: return
          var keyVal = '- **' + a.key + '**: '
          text += '\n\n' + keyVal
          var lastText = ''
          if keyVal in oldmd:
            lastText = oldmd.split(keyVal)[1].split("\n")[0]
          if lastText:
            text += lastText
            continue
          else:
            text += await global.prompt("setting: " + a.key, global.PromptTypes.string)
  # text+="- **input detector**"
  log.pp(text)
  global.file.write("res://test.md", text, false)