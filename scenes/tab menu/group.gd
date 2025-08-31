extends NestedSearchable

func _on_folding_changed(is_folded: bool) -> void:
  global.tabMenu.saveFoldingState()
