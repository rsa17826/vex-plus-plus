extends Control

var buttons: Array[Button] = []

func setWords(words: Array):
  while len(buttons) < len(words):
    var button = Button.new()
    button.pressed.connect(buttonPressed.bind(button))
    button.gui_input.connect(keyPressed.bind(button))
    buttons.append(button)
    add_child(button)
  for button in buttons:
    button.visible = false
  for i in range(len(words)):
    buttons[i].visible = true
    buttons[i].text = words[i]

func buttonPressed(button: Button):
  $search.completeWord(button.text)

func keyPressed(event: InputEvent, button: Button) -> void:
  if Input.is_action_just_pressed(&"tab", true):
    log.pp(button.text)