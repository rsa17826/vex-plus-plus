extends Button

var version
var levelName: String

func _on_button_open_in_correct_version_pressed() -> void:
  if DirAccess.remove_absolute(global.path.abs("res://process")):
    DirAccess.remove_absolute(global.path.abs("res://process"))
  if FileAccess.file_exists(r"..\..\vex++.exe"):
    OS.create_process(r"..\..\vex++.exe", PackedStringArray([
      "version", str(version), "silent", "--loadMap", levelName
    ]))
  else:
    OS.create_process(r"..\..\vex++.cmd", PackedStringArray([
      "version", str(version), "silent", "--loadMap", levelName
    ]))
  global.quitGame()
  # OS.kill(OS.get_process_id())