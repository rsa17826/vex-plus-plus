extends RichTextLabel

@export var searchBar: Control

func updateText(textArr: Array) -> void:
  text = ''
  # var tlen = 0
  for thing in textArr:
    # tlen += len(thing[0])
    match thing[1]:
      "keyword":
        text += "[color=#3498db]" + thing[0] + "[/color]"
      "error":
        text += "[color=#E74C3C]" + thing[0] + "[/color]"
      "data":
        text += "[color=#2ECC71]" + thing[0] + "[/color]"
      "current":
        text += "[color=#946712]" + thing[0] + "[/color]"
      _:
        text += "[color=#156472]" + thing[0] + "[/color]"
    text += '/'
  text = text.trim_suffix('/')
  size = searchBar.size
  scale.x = .975
  # log.pp(scale.x, text, tlen)
