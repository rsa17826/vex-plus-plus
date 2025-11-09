extends LineEdit

@export var autoCompleteUi: Control
@export var rtl: RichTextLabel

func _unhandled_key_input(event: InputEvent) -> void:
  if autoCompleteUi.focusAsSearchBar and Input.is_action_just_pressed(&"focus_search", true):
    grab_focus()
    get_viewport().set_input_as_handled()

var textArr = []

func getAutocomplete(text: String) -> Array:
  var words: Array = text.strip_edges().split("/")
  var posableWords = autoCompleteUi.autoComplete.keys()
  # if text.ends_with("/") or not text:
  #   return posableWords
  textArr = []
  var lastWord = words[-1].to_lower()
  var delay = 0
  var lastValidWord: String = ''

  for kw in autoCompleteUi.autoComplete:
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
    if word in autoCompleteUi.autoComplete:
      lastValidWord = word
      delay = autoCompleteUi.autoComplete[word]
      textArr.append([word, "keyword"])
      continue
    if not (lastValidWord in autoCompleteUi.autoComplete):
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
      # log.err("error at " + lastValidWord + " expected word count of " + str(autoCompleteUi.autoComplete[lastValidWord]) + " got extra word " + word)
    # return []

  return posableWords

var idx := 0
func _on_gui_input(event: InputEvent) -> void:
  if event is InputEventKey and event.is_pressed():
    if Input.is_action_just_pressed(&"ui_copy", true) and has_selection():
      DisplayServer.clipboard_set(get_selected_text())
    if Input.is_action_just_pressed(&"ui_cut", true) and has_selection():
      DisplayServer.clipboard_set(get_selected_text())
      var start = get_selection_from_column()
      delete_text(start, get_selection_to_column())
      deselect()
      caret_column = start
    if Input.is_action_just_pressed(&"ui_cancel", true):
      release_focus()
      get_viewport().set_input_as_handled()
      return
    elif Input.is_action_just_pressed(&"accept_autocomplete", true) \
    or Input.is_action_just_pressed(&"ui_up", true) \
    or Input.is_action_just_pressed(&"ui_down", true) \
    or (
      global.useropts.autocompleteSearchBarHookLeftAndRight
      and (
        Input.is_action_just_pressed(&"ui_left", true)
        or Input.is_action_just_pressed(&"ui_right", true)
      )
    ) \
    :
      get_viewport().set_input_as_handled()
    await global.wait()
    var w = getAutocomplete(text)
    if not Input.is_action_just_pressed(&"accept_autocomplete", true):
      idx = autoCompleteUi.lastSelected
      if (
        Input.is_action_just_pressed(&"ui_up", true) or (
          global.useropts.autocompleteSearchBarHookLeftAndRight
          and Input.is_action_just_pressed(&"ui_left", true)
        )
      ) and w:
        if not len(w): return
        idx -= 1
        idx = idx % len(w)
        while idx < 0:
          idx += len(w)
      elif Input.is_action_just_pressed(&"ui_down", true) or (
        global.useropts.autocompleteSearchBarHookLeftAndRight
        and Input.is_action_just_pressed(&"ui_right", true)
      ) and w:
        if not len(w): return
        idx += 1
        idx = idx % len(w)
        while idx < 0:
          idx += len(w)
      else:
        idx = -1
    autoCompleteUi.setWords(w)
    if len(w) and idx > -1:
      autoCompleteUi.setSelected(idx)
    if Input.is_action_just_pressed(&"accept_autocomplete", true) and w:
      completeWord(autoCompleteUi.buttons[autoCompleteUi.lastSelected].text)
      autoCompleteUi.setWords(getAutocomplete(text))
      autoCompleteUi.setSelected(0)
      idx = 0
    rtl.updateText(textArr)

func completeWord(newWord: String) -> void:
  var lastPos = get_caret_column()
  var words = text.strip_edges().split("/")
  var oldWord: String
  if text.ends_with("/"):
    oldWord = ''
    words.append(newWord)
  else:
    oldWord = words[-1]
    words[-1] = newWord
  text = "/".join(words).replace("//", "/") + '/'
  set_caret_column(lastPos - len(oldWord) + len(newWord) + 1)

func _on_focus_exited() -> void:
  log.pp(autoCompleteUi.clearOnFocusLoss, "asasas")
  if autoCompleteUi.clearOnFocusLoss:
    autoCompleteUi.setWords([])

func _on_focus_entered() -> void:
  if text:
    var w = getAutocomplete(text)
    autoCompleteUi.setWords(w)
  else:
    autoCompleteUi.setWords(autoCompleteUi.autoComplete.keys())
