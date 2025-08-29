extends Button

var version: int
var levelName: String

func _on_button_open_in_correct_version_pressed() -> void:
  OS.create_process(r"..\..\vex++.exe", PackedStringArray([
    "version", str(version), "silent", "--loadMap", levelName
  ]))
  get_tree().quit()