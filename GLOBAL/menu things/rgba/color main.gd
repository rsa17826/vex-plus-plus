extends NestedSearchable
signal onchanged()
func init(thing, menu_data, formatName, _self):
  $Label.text = formatName.call(thing.name)
  $HSlider.color = Color.hex(int(thing.user))
  $HSlider.popup_closed.connect(func(...__):
    onchanged.emit()
  )
  tooltip_text = thing.tooltip
