extends Button

var version
var levelName: String

func _on_button_open_in_correct_version_pressed() -> void:
  global.openLevelInVersion(levelName, version)
  # OS.kill(OS.get_process_id())