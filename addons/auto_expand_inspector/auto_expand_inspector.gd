@tool
extends EditorPlugin

#----------------------------------------------------------------------------------------

func _enter_tree() -> void:
	EditorInterface.get_selection().selection_changed.connect(on_selection_changed)


func _exit_tree() -> void:
	EditorInterface.get_selection().selection_changed.disconnect(on_selection_changed)

#----------------------------------------------------------------------------------------

func on_selection_changed() -> void:
	await get_tree().create_timer(0.1).timeout
	find_unfoldable_nodes()

#----------------------------------------------------------------------------------------

func find_unfoldable_nodes():
	find_unfoldable_nodes_on_children(get_tree().root)


func find_unfoldable_nodes_on_children(node: Node):
	if node.has_method("unfold"):
		node.unfold()
	else:
		for child in node.get_children():
			find_unfoldable_nodes_on_children(child)
