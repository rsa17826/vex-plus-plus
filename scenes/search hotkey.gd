extends LineEdit
func _unhandled_key_input(event: InputEvent) -> void:
  if Input.is_action_just_pressed(&"focus_search", true):
    grab_focus()
    get_viewport().set_input_as_handled()

@onready var autoCompleteUi: Control = get_parent()

var autoComplete = {
  "creatorId:": 1,
  "creatorName:": 1,
  "levelName:": 1,
  "gameVersion:": 1,
  "levelVersion:": 1,
}

func getAutoComplete(text: String) -> Array:
  var words: Array = text.strip_edges().split(" ")
  var posableWords = autoComplete.keys()
  if text.ends_with(" "):
    return posableWords
  var lastWord = words[-1].to_lower()
  var delay = 0
  var lastValidWord: String = ''
  for kw in autoComplete:
    var idx = 0
    for char in lastWord:
      if idx > len(kw): break
      if kw.to_lower().find(char, idx) != -1:
        idx = kw.to_lower().find(char, idx) + 1
      else:
        posableWords.erase(kw)
        break
  for word in words:
    if delay:
      delay -= 1
      continue
    if word in autoComplete:
      lastValidWord = word
      delay = autoComplete[word]
      continue
    if not (lastValidWord in autoComplete):
      log.err("error, " + word + " is not a valid keyword")
    else:
      if posableWords:
        return posableWords
      log.err("error at " + lastValidWord + " expected word count of " + str(autoComplete[lastValidWord]) + " got extra word " + word)
    return []
  return posableWords

func _ready() -> void:
  global.fullscreen(-1)

func _on_gui_input(event: InputEvent) -> void:
  var w = getAutoComplete(text)
  autoCompleteUi.setWords(w)
  if Input.is_action_just_pressed(&"tab", true) and w:
    completeWord(autoCompleteUi.buttons[0].text)
func completeWord(newWord: String) -> void:
  var lastPos = get_caret_column()
  var words = text.strip_edges().split(" ")
  var oldWord: String
  if text.ends_with(" "):
    oldWord = ''
    words.append(newWord)
  else:
    oldWord = words[-1]
    words[-1] = newWord
  text = " ".join(words)
  set_caret_column(lastPos - len(oldWord) + len(newWord))
  get_viewport().set_input_as_handled()