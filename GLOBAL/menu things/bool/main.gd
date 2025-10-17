extends NestedSearchable
signal onchanged()
func init(thing, menu_data, formatName, _self):
  $Label.text = formatName.call(thing.name)
  $CheckButton.button_pressed = thing.user
  $CheckButton.toggled.connect(func(...__):
    onchanged.emit()
  )
