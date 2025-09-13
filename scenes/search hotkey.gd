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

var textArr = []

func getAutoComplete(text: String) -> Array:
  var words: Array = text.strip_edges().split(" ")
  var posableWords = autoComplete.keys()
  if text.ends_with(" ") or not text:
    return posableWords
  textArr = []
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
  var remainingWordsCount = len(words)
  for word in words:
    remainingWordsCount -= 1
    if delay:
      delay -= 1
      textArr.append([word, "data"])
      continue
    if word in autoComplete:
      lastValidWord = word
      delay = autoComplete[word]
      textArr.append([word, "keyword"])
      continue
    if not (lastValidWord in autoComplete):
      if !remainingWordsCount and posableWords:
        textArr.append([word, "current"])
        continue
      textArr.append([word, "error"])
      continue
      # log.err("error, " + word + " is not a valid keyword")
    else:
      # if posableWords:
      #   return posableWords
      textArr.append([word, "error"])
      continue
      # log.err("error at " + lastValidWord + " expected word count of " + str(autoComplete[lastValidWord]) + " got extra word " + word)
    # return []

  return posableWords

func _ready() -> void:
  global.fullscreen(-1)
var idx := 0
func _on_gui_input(event: InputEvent) -> void:
  if event is InputEventKey and not event.is_echo() and event.is_pressed():
    if Input.is_action_just_pressed(&"tab", true) \
    or Input.is_action_just_pressed(&"ui_up", true) \
    or Input.is_action_just_pressed(&"ui_down", true) \
    :
      get_viewport().set_input_as_handled()
    await global.wait()
    var w = getAutoComplete(text)
    if not Input.is_action_just_pressed(&"tab", true):
      if Input.is_action_just_pressed(&"ui_up", true):
        idx -= 1
        idx = idx % len(w)
      elif Input.is_action_just_pressed(&"ui_down", true):
        idx += 1
        idx = idx % len(w)
      else:
        idx = 0
    autoCompleteUi.setWords(w)
    if len(w):
      autoCompleteUi.setSelected(idx)
    if Input.is_action_just_pressed(&"tab", true) and w:
      completeWord(autoCompleteUi.buttons[idx].text)
      autoCompleteUi.setWords(getAutoComplete(text))
    $RichTextLabel.updateText(textArr)

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

func _on_focus_exited() -> void:
  autoCompleteUi.setWords([])

func _on_focus_entered() -> void:
  autoCompleteUi.setWords(autoComplete.keys())
