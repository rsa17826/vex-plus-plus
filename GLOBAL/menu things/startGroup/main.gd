extends NestedSearchable

signal onchanged()
var vbox = VBoxContainer.new()
func init(thing, menu_data, formatName, _self):
  _self.folded = !menu_data.dontCollapseGroups.user
  # if menu_data.onlyExpandSingleGroup.user and not menu_data.dontCollapseGroups.user:
  #   if !GROUP:
  #     GROUP = FoldableGroup.new()
  #   _self.foldable_group = GROUP
  # var name = "/".join(currentParent.slice(1).map(func(e): return e.get_parent().title) + [thing.name.substr(len("startGroup - "))])
  if menu_data.loadExpandedGroups.user and not menu_data.dontCollapseGroups.user:
    _self.folded = !thing.user
  _self.folding_changed.connect(func(folded):
    if folded and menu_data.dontCollapseGroups.user:
      _self.folded=false
    if menu_data.saveExpandedGroups.user \
    if 'user' in menu_data.saveExpandedGroups \
    else menu_data.saveExpandedGroups.default:
      menu_data[thing.name].user=!_self.folded
    onchanged.emit()
    )
  _self.title = formatName.call(thing.shortName)
  _self.thisText = _self.title

  _self.add_child(vbox)

func postInit(currentParent):
  currentParent.append(vbox)