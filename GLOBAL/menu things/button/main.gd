extends NestedSearchable
signal onchanged()
func init(thing, menu_data, formatName, _self):
  thisText = formatName.call(thing.name)
  $Button.text = formatName.call(thing.name)
  $Button.pressed.connect(thing.onclick)