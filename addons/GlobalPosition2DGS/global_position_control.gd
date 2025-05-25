@tool
extends GridContainer
@export var _line_editX: LineEdit
@export var _line_editY: LineEdit
@export var _line_edit_rot: LineEdit

var object : Node2D
var undo_redo : EditorUndoRedoManager

var old_x: float
var old_y: float
var old_rot: float

func _set_object(new_object : Node2D) -> void:
	object = new_object

func _ready() -> void:
	_line_editX.text_submitted.connect(_edit_x)
	_line_editY.text_submitted.connect(_edit_y)
	_line_edit_rot.text_submitted.connect(_edit_rot)
	
	_line_editX.focus_entered.connect(_store_old_x)
	_line_editY.focus_entered.connect(_store_old_y)
	_line_edit_rot.focus_entered.connect(_store_old_rot)

func _store_old_x():
	if object:
		old_x = object.global_position.x

func _store_old_y():
	if object:
		old_y = object.global_position.y

func _store_old_rot():
	if object:
		old_rot = object.global_rotation

func _process(delta: float) -> void:
	if object == null:
		return
	if(!_line_editX.has_focus()):
		_line_editX.text = str(object.global_position.x)
	if(!_line_editY.has_focus()):
		_line_editY.text = str(object.global_position.y)
	if(!_line_edit_rot.has_focus()):
		_line_edit_rot.text = str(object.global_rotation)

func _edit_x(new_x : String) -> void:
	if new_x.is_valid_float() and object:
		var new_val = new_x.to_float()
		var old_pos = object.global_position
		var new_pos = Vector2(new_val, old_pos.y)
		if undo_redo and new_val != old_x:
			undo_redo.create_action("Change global X position")
			undo_redo.add_do_property(object, "global_position", new_pos)
			undo_redo.add_do_property(_line_editX, "text", str(new_x))
			undo_redo.add_undo_property(object, "global_position", old_pos)
			undo_redo.add_undo_property(_line_editX, "text", str(old_x))
			undo_redo.commit_action()
		else:
			object.global_position = new_pos
	else:
		_line_editX.text = str(object.global_position.x)
	

#func  _edit_y(new_y : String) -> void:
	#if(new_y.is_valid_float()):
		#object.global_position = Vector2(object.global_position.y,new_y.to_float())
		#return
	#_line_editY.text = str(object.global_position.y)

func  _edit_y(new_y : String) -> void:
	if new_y.is_valid_float() and object:
		var new_val = new_y.to_float()
		var old_pos = object.global_position
		var new_pos = Vector2(old_pos.x, new_val)
		if undo_redo and new_val != old_x:
			undo_redo.create_action("Change global Y position")
			undo_redo.add_do_property(object, "global_position", new_pos)
			undo_redo.add_do_property(_line_editY, "text", str(new_y))
			undo_redo.add_undo_property(object, "global_position", old_pos)
			undo_redo.add_undo_property(_line_editY, "text", str(old_y))
			undo_redo.commit_action()
		else:
			object.global_position = new_pos
	else:
		_line_editY.text = str(object.global_position.y)
	
func _edit_rot(new_rot : String):
	if new_rot.is_valid_float() and object:
		var new_val = new_rot.to_float()
		var old_rot = object.global_rotation
		if undo_redo and new_val != old_rot:
			undo_redo.create_action("Change global rotation")
			undo_redo.add_do_property(object, "global_rotation", new_val)
			undo_redo.add_do_property(_line_edit_rot, "text", str(new_val))
			undo_redo.add_undo_property(object, "global_rotation", old_rot)
			undo_redo.add_undo_property(_line_edit_rot, "text", str(old_rot))
			undo_redo.commit_action()
		else:
			object.global_rotation = new_rot.to_float()
	else:
		_line_edit_rot.text = str(object.global_rotation)
	
func set_undo_redo(undo_redo_instance: EditorUndoRedoManager):
	undo_redo = undo_redo_instance
