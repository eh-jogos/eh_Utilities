extends EditorResourcePicker

# Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const ID_OFFSET = 1_000_000

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _custom_classes_by_name := {}
var _custom_inheritance_by_class := {}

var _allowed_classes := []
var _allowed_class_scripts := []

var _valid_ids := {}

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func set_create_options(menu_node: Object) -> void:
	var popup_menu = menu_node as PopupMenu
	for index in _allowed_classes.size():
		var id: int = ID_OFFSET + index
		popup_menu.add_item("New %s"%[_allowed_classes[index]], id)
		_valid_ids[id] = _allowed_class_scripts[index]
	
	popup_menu.add_separator("")


func handle_menu_selected(id: int):
	var has_handled := false
	print("id: %s"%[id])
	
	if _valid_ids.has(id):
		has_handled = true
		var script := load(_valid_ids[id]) as GDScript
		var new_resource = script.new()
		emit_signal("resource_changed", new_resource)
	
	return has_handled

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func set_allowed_classes(
			reference_class: String,
			p_custom_classes: Dictionary, 
			p_custom_inheritance: Dictionary
	) -> void:
#	print("custom_classes: %s"%[p_custom_classes])
	_custom_classes_by_name = p_custom_classes
	_custom_inheritance_by_class = p_custom_inheritance
	
	if reference_class in _custom_inheritance_by_class:
		_allowed_classes.append(reference_class)
		_build_allowed_classes(reference_class)
	else:
		push_error("Could not find %s in custom classes"%[reference_class])


func _build_allowed_classes(p_class: String) -> void:
	if _custom_inheritance_by_class.has(p_class):
		_allowed_classes.append_array(_custom_inheritance_by_class[p_class])
		_allowed_class_scripts.append(_custom_classes_by_name[p_class].path)
	
	for inherited_class in _custom_inheritance_by_class[p_class]:
		_build_allowed_classes(inherited_class)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
