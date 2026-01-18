extends Control

var buttons: Array[Label] = []
@export var focusAsSearchBar: bool = false
@export var edit: Control
@export var rtl: Control
@export var clearOnFocusLoss := true

@export var autoComplete = {
  "creatorId": 1,
  "creatorName": 1,
  "levelName": 1,
  "gameVersion": 1,
  "levelVersion": 1,
}
var lastWords = []

func setWords(words: Array):
  (
    $HBoxContainer if
    global.useropts.searchBarHorizontalAutocomplete
    else $VBoxContainer
  ).visible = global.useropts.showAutocompleteOptions != 0
  if '/'.join(words) == '/'.join(lastWords): return
  lastWords = words
  while len(buttons) < len(words):
    var button = Label.new()
    buttons.append(button)
    (
      $HBoxContainer if
      global.useropts.searchBarHorizontalAutocomplete
      else $VBoxContainer
    ).add_child(button)
  for button in buttons:
    button.visible = false
  for i in range(len(words)):
    buttons[i].visible = true
    buttons[i].text = words[i]
  setSelected(0)
var lastSelected: int = -1
func setSelected(idx: int):
  lastSelected = idx
  for btn in buttons:
    btn.modulate = Color(1, 1, 1)
  if idx >= len(buttons): return
  buttons[idx].modulate = Color(1, 0.5, 0)

signal text_changed(new_text: String, textArr: Array)
signal text_submitted(new_text: String, textArr: Array)

var text:
  get():
    return edit.text
  set(text):
    if not global.useropts: return
    edit.text = text
    var w = edit.getAutocomplete(text)
    setWords(w)
    rtl.updateText(edit.textArr)
    text_changed.emit(text, edit.textArr)
    if clearOnFocusLoss and !edit.focused:
      setWords([])

var textArr:
  get():
    return edit.textArr

func _on_line_edit_text_submitted(new_text: String) -> void:
  text_submitted.emit(new_text, edit.textArr)

func _on_line_edit_text_changed(new_text: String) -> void:
  if new_text.begins_with(" "):
    text = new_text.lstrip(" ")
  text_changed.emit(new_text, edit.textArr)
  if not text:
    setWords([])
    setSelected(0)
    rtl.updateText([])

func _ready() -> void:
  if not global.useropts:
    await global.wait()
  clearOnFocusLoss = global.useropts.showAutocompleteOptions != 2
  if global.useropts.showAutocompleteOptions == 2:
    var w = edit.getAutocomplete(text)
    setWords(w)
