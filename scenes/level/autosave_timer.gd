extends Timer
func _ready() -> void:
  if global.useropts.autosaveInterval:
    self.wait_time = global.useropts.autosaveInterval
    self.start()

func _on_timeout() -> void:
  if global.showEditorUi \
  and get_window().has_focus() \
  and not global.tabMenu.visible \
  and not global.ctrlMenu.visible \
  :
    global.level.save(true)
