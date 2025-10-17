extends NestedSearchable
signal onchanged()
func init(thing, menu_data, formatName, _self):
  thisText = formatName.call(thing.name)
  $Label.text = formatName.call(thing.name)
  $TextEdit.text = thing.user
  $TextEdit.placeholder_text = thing.placeholder
  $TextEdit.text_changed.connect(func(...__):
    onchanged.emit()
  )
