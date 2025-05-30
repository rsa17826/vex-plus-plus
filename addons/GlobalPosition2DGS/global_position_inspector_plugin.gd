@tool
extends EditorInspectorPlugin

var undo_redo: EditorUndoRedoManager

func _can_handle(object: Object) -> bool:
    if(object is Node2D):
        return true
    return false

func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
    if(name == "position"):
        var _custon_control := preload("res://addons/GlobalPosition2DGS/GlobalPosition.tscn").instantiate()
        _custon_control.set_undo_redo(undo_redo)
        add_custom_control(_custon_control)
        if(_custon_control.has_method("_set_object")):
            _custon_control._set_object(object)
    
    return false
    
func set_undo_redo(undo_redo_instance: EditorUndoRedoManager):
    undo_redo = undo_redo_instance
