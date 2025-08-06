extends FileDialog

func _on_button_pressed() -> void:
  var file: String = files if files is String else files[0]
  current_dir = file.get_base_dir()
  current_path = file
  visible = true

var single: bool = true
var files: Variant

func _on_files_selected(paths: PackedStringArray) -> void:
  files = paths

func _on_file_selected(path: String) -> void:
  files = path

func _on_button_clear_pressed() -> void:
  files = '' if single else []
