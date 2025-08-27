@tool
extends EditorPlugin

var plugin

func _enter_tree() -> void:
    plugin = preload("res://addons/GlobalPosition2DGS/global_position_inspector_plugin.gd").new()
    plugin.set_undo_redo(get_undo_redo())
    add_inspector_plugin(plugin)
func  _exit_tree() -> void:
    remove_inspector_plugin(plugin)
