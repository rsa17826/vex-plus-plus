extends NestedSearchable

func _ready() -> void:
  searchMatchedThis.connect(unfold)
  searchMatchedChildren.connect(unfold)
  searchCleared.connect(resetfold)
  self.folding_changed.connect(updateLastFolded)
  lastFolded = self.folded

var lastFolded: bool = false
func updateLastFolded(isFolded: bool) -> void:
  lastFolded = isFolded

func unfold():
  self.folded = false

func resetfold():
  self.folded = lastFolded