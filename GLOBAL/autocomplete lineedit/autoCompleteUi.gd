extends Control

var buttons: Array[Label] = []
@export var focusAsSearchBar: bool = false

@export var autoComplete = {
  "creatorId": 1,
  "creatorName": 1,
  "levelName": 1,
  "gameVersion": 1,
  "levelVersion": 1,
}

func setWords(words: Array):
  while len(buttons) < len(words):
    var button = Label.new()
    buttons.append(button)
    add_child(button)
  for button in buttons:
    button.visible = false
  for i in range(len(words)):
    buttons[i].visible = true
    buttons[i].text = words[i]
  setSelected(0)

func setSelected(idx: int):
  for btn in buttons:
    btn.modulate = Color(1, 1, 1)
  if idx >= len(buttons): return
  buttons[idx].modulate = Color(1, 0.5, 0)

signal text_changed(new_text: String, textArr: Array)
signal text_submitted(new_text: String, textArr: Array)

var text:
  get():
    return $LineEdit.text
  set(text):
    $LineEdit.text = text
    var w = $LineEdit.getAutoComplete(text)
    setWords(w)
    setSelected(0)
    $LineEdit/RichTextLabel.updateText($LineEdit.textArr)

var textArr:
  get():
    return $LineEdit.textArr

func _on_line_edit_text_submitted(new_text: String) -> void:
  text_submitted.emit(new_text, $LineEdit.textArr)

func _on_line_edit_text_changed(new_text: String) -> void:
  text_changed.emit(new_text, $LineEdit.textArr)
