extends NestedSearchable
signal onchanged()
func init(thing, menu_data, formatName, _self):
  $Label.text = formatName.call(thing.name)
  var range_node = $HSlider
  range_node.rounded = thing.rounded
  range_node.allow_greater = thing.allow_greater
  range_node.allow_lesser = thing.allow_lesser
  range_node.min_value = thing.from
  range_node.max_value = thing.to
  range_node.step = thing.step
  range_node.value = thing.user
  range_node.value_changed.connect(func(...__):
    onchanged.emit()
  )
  tooltip_text = thing.tooltip
