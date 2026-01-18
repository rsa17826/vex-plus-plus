extends NestedSearchable
signal onchanged()
func init(thing, menu_data, formatName, _self):
  $Label.text = formatName.call(thing.name)
  var lineEditNode = $LineEdit
  lineEditNode.text = thing.user
  lineEditNode.placeholder_text = thing.placeholder
  lineEditNode.text_changed.connect(func(...__):
    onchanged.emit()
  )
  tooltip_text = thing.tooltip
