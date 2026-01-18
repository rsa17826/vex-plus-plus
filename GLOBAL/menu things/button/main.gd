extends NestedSearchable
signal onchanged()
func init(thing, menu_data, formatName, _self):
  $Button.text = formatName.call(thing.name)
  $Button.pressed.connect(thing.onclick)
  $Button.pressed.connect(func(...__):
    onchanged.emit()
  )
  tooltip_text = thing.tooltip
