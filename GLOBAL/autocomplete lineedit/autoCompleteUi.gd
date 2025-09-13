extends Control

var buttons: Array[Label] = []

func setWords(words: Array):
  while len(buttons) < len(words):
    var button = Label.new()
    # button.pressed.connect(buttonPressed.bind(button))
    # button.gui_input.connect(keyPressed.bind(button))
    buttons.append(button)
    add_child(button)
  for button in buttons:
    button.visible = false
  for i in range(len(words)):
    buttons[i].visible = true
    buttons[i].text = words[i]
  setSelected(0)

func buttonPressed(button: Label):
  $search.completeWord(button.text)

func keyPressed(event: InputEvent, button: Label) -> void:
  if Input.is_action_just_pressed(&"tab", true):
    log.pp(button.text)

func setSelected(idx: int):
  for btn in buttons:
    btn.modulate = Color(1, 1, 1)
  if idx >= len(buttons): return
  buttons[idx].modulate = Color(1, 0.5, 0)