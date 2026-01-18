extends NestedSearchable
signal onchanged()
func init(thing, menu_data, formatName, _self):
  $Label.text = formatName.call(thing.name)
  $Button.text = 'pick a file' if thing.single else 'pick files'
  var fileNode = $FileDialog
  fileNode.files = thing.user
  fileNode.single = thing.single
  fileNode['file_selected' if thing.single else 'files_selected'].connect(func(...__):
    onchanged.emit()
  )
  $ButtonClear.pressed.connect(func(...__):
    onchanged.emit()
  )
  tooltip_text = thing.tooltip
