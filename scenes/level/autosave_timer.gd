extends Timer
func _ready() -> void:
  if global.useropts.autosaveInterval:
    self.wait_time = global.useropts.autosaveInterval
    self.start()

func _on_timeout() -> void:
  if global.showEditorUi:
    global.level.save()
