# Class to automate serializing any object into dicts and loading it back.
# To use it, just call the public methods from wherever in your code:
# `get_dict_from` and `load_dict_into`
class_name eh_Serializer
extends Reference

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

static func get_dict_from(instance: Object) -> Dictionary:
	var dict = inst2dict(instance)
	for key in dict.keys():
		if key in instance:
			dict[key] = _handle_recursive_inst_serializing(instance.get(key))
	
	if "resource_path" in instance and instance.resource_path != "" and not instance.resource_path.find("::"):
		dict.resource_path = instance.resource_path
	
	return dict


static func load_dict_into(dict: Dictionary, instance: Object) -> bool:
	var success: = true
	var dict_instance = dict2inst(dict)
	
	if instance.get_class() == dict_instance.get_class():
		for key in dict.keys():
			if key == "resource_path":
				continue
			
			if key in instance:
				instance.set(key, _handle_recursive_serialized_loading(dict[key]))
	else:
		success = false
		push_error("Failed loading dict. You can't load %s into %s"%[
			dict_instance.get_class(), 
			instance.get_class()
		])
	
	return success

### -----------------------------------------------------------------------------------------------

### Private Methods -------------------------------------------------------------------------------

static func _is_instance_dict(p_value) -> bool:
	var is_dict: = p_value is Dictionary
	var has_inst_keys: bool = p_value.has("@subpath") and p_value.has("@path") if is_dict else false
	return is_dict and has_inst_keys


static func _handle_recursive_inst_serializing(value):
	var to_return
	
	if value is Object:
		to_return =_handle_saving_object(value)
	elif value is Dictionary:
		to_return = _handle_saving_dictionary(value)
	elif value is Array:
		to_return = _handle_saving_array(value)
	else:
		to_return = value
	
	return to_return


static func _handle_saving_object(p_object: Object):
	var to_return
	
	if p_object.get_script() != null:
		to_return = get_dict_from(p_object)
	else:
		to_return = var2str(p_object)
	
	return to_return


static func _handle_saving_dictionary(p_dict: Dictionary) -> Dictionary:
	var to_return: = p_dict.duplicate(true)
	for key in to_return.keys():
		to_return[key] = _handle_recursive_inst_serializing(to_return[key])
	
	return to_return


static func _handle_saving_array(p_array: Array) -> Array:
	var to_return: = p_array.duplicate(true)
	for index in to_return.size():
		to_return[index] = _handle_recursive_inst_serializing(to_return[index])
	
	return to_return


static func _handle_recursive_serialized_loading(value):
	var to_return
	
	if value is Dictionary:
		to_return = _handle_loading_dictionary(value)
	elif value is Array:
		to_return = _handle_loading_array(value)
	elif value is String:
		to_return = str2var(value)
	else:
		to_return = value
	
	return to_return


static func _handle_loading_object(p_object: Object) -> Object:
	var to_return: Object
	
	var property_list = p_object.get_property_list()
	for dict in p_object.get_property_list():
		var key = dict.name
		var value = p_object.get(key)
		
		if value is Dictionary:
			p_object.set(key, _handle_loading_dictionary(value))
		elif value is Array:
			p_object.set(key, _handle_loading_array(value))
	
	to_return = p_object
	
	return to_return


static func _handle_loading_dictionary(p_dict: Dictionary):
	var to_return = p_dict.duplicate(true)
	if _is_instance_dict(p_dict):
		var nested_instance
		
		if p_dict.has("resource_path") and ResourceLoader.exists(p_dict["resource_path"]):
			nested_instance = load(p_dict["resource_path"])
		else:
			nested_instance = dict2inst(p_dict)
		
		nested_instance = dict2inst(p_dict)
		
		to_return = _handle_loading_object(nested_instance)
	else:
		for key in to_return.keys():
			to_return[key] = _handle_recursive_serialized_loading(to_return[key])
	
	return to_return


static func _handle_loading_array(p_array: Array) -> Array:
	var to_return: = p_array.duplicate(true)
	for index in to_return.size():
		to_return[index] = _handle_recursive_serialized_loading(to_return[index])
	
	return to_return

### -----------------------------------------------------------------------------------------------
