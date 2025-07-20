extends GridContainer

func _process(delta: float) -> void:
  if global.useropts.showLevelModsWhilePlaying and !global.showEditorUi:
    visible = true
  elif global.useropts.showLevelModsWhileEditing and global.showEditorUi:
    visible = true
  else:
    visible = false