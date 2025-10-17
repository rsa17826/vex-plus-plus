extends NestedSearchable
signal onchanged()
func init(thing, menu_data, formatName, _self):
  $Label.text = formatName.call(thing.name)
  # $OptionButton.value = str(thing.user)
  var select = $OptionButton
  select.clear()
  for opt in thing.options:
    select.add_item(opt)
  select.select(int(thing.user) if "user" in thing else 0)
  select.item_selected.connect(func(...__):
    onchanged.emit()
  )
