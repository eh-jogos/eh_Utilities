# Write your doc string for this file here
tool
extends PanelContainer

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

export(Array, Resource) var debug_variables_list: Array = [] \
		setget _set_debug_variables_array, _get_debug_variables_array

#--- private variables - order: export > normal var > onready -------------------------------------

onready var _list: VBoxContainer = $List

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if eh_EditorHelpers.is_editor():
		eh_EditorHelpers.disable_all_processing(self)
	pass

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func update_debug_display() -> void:
	if not is_inside_tree() or not _list:
		yield(self, "ready")
	
	if eh_EditorHelpers.is_editor():
		return
	
	for child in _list.get_children():
		_list.remove_child(child)
		child.queue_free()
	
	var list: = _get_cleaned_variables_list()
	for index in list.size():
		var shared_variable: SharedVariable = debug_variables_list[index]
		if not shared_variable:
			continue
		
		var label = Label.new()
		var variable_name = shared_variable.resource_path.get_basename()\
				.lstrip(shared_variable.resource_path.get_base_dir())
		label.text = "%s: %s"%[variable_name, shared_variable.value]
		_list.add_child(label)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _get_cleaned_variables_list() -> Array:
	var clean_copy = debug_variables_list.duplicate()
	
	for index in range(clean_copy.size() -1 , -1, -1):
		if clean_copy[index] == null:
			clean_copy.remove(index)
	
	return clean_copy


func _set_debug_variables_array(value: Array) -> void:
	for index in range(value.size() - 1 , -1, -1):
		if value[index] == null:
			continue
		
		var shared_variable: SharedVariable = value[index]
		if not shared_variable:
			value.remove(index)
		else:
			shared_variable.connect_to(self, "update_debug_display")
	
	debug_variables_list = value
	update_debug_display()


func _get_debug_variables_array() -> Array:
	for index in range(debug_variables_list.size() - 1 , -1, -1):
		var object: Object = debug_variables_list[index]
		if object == null:
			continue
		elif not object.has_signal("value_updated"):
			debug_variables_list.erase(object)
	
	return debug_variables_list

### -----------------------------------------------------------------------------------------------
