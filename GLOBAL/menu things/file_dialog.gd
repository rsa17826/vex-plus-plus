extends FileDialog

func _on_button_pressed() -> void:
  visible = true

var files

func _on_files_selected(paths: PackedStringArray) -> void:
  files = paths

func _on_file_selected(path: String) -> void:
  files = path
