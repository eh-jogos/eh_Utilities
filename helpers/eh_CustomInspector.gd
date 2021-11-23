# Class to help export custom resources as properties into the inspector while maintaining the
# variables in your code with their respective custom types. Used by the node 
# `eh_CustomEditorControls` to make the process fully automated. 
#
# But you can use this directly as well if you wish, by instancing it in any script and then 
# delegating the `_get_property_list`, `_get` and `_set` methods to it.  
#
# Example snippet to copy-paste where you want to use it directly:
#
###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################
#
#var _custom_inspector: eh_CustomInspector = eh_CustomInspector.new(
#	object,
#	[properties [grouped_properties]],
#	"category"
#)
#
#### Editor Methods --------------------------------------------------------------------------------
#
#func _get_property_list() -> Array:
#	var properties: = _custom_inspector._get_property_list()
#	return properties
#
#
#func _get(property: String):
#	return _custom_inspector._get(property)
#
#
#func _set(property: String, value) -> bool:
#	var has_handled: = _custom_inspector._set(property, value)
#	if has_handled:
#		update_configuration_warning()
#		property_list_changed_notify()
#	return has_handled
#
#
#func _get_configuration_warning() -> String:
#	var msg: = ""
#
#	return msg
#
#### -----------------------------------------------------------------------------------------------

class_name eh_CustomInspector
extends Reference

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

var custom_properties: Dictionary = {}
var node_origin: Node

#--- private variables - order: export > normal var > onready -------------------------------------

var property_values: Dictionary = {}
var _category_name: String = ""

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _init(p_origin: Node, properties: Array, category: String = "") -> void:
	node_origin = p_origin
	_category_name = category
	for property in properties:
		if property is Dictionary:
			_build_group_of_properties(property)
		else:
			var key: String = "_%s"%[property]
			custom_properties[key] = property


func _set(property: String, value) -> bool:
	var has_handled: = false
	
	var original_property: String = _get_original_property(property)
	if original_property != "":
		node_origin.set(original_property, value)
		has_handled = node_origin.get(original_property) == value
	
	return has_handled


func _get(property: String):
	var to_return = null
	var original_property: String = _get_original_property(property)
	if original_property != "":
		to_return = node_origin.get(original_property)
	
	return to_return


func _get_property_list() -> Array:
	var properties: = _get_treated_property_list()
	return properties

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func has_property(p_property: String) -> bool:
	return custom_properties.has(p_property)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _build_group_of_properties(group: Dictionary) -> void:
	for key in group:
		var group_name: String = key as String
		if not group_name:
			push_error("Every key from a group dictionary must be a string for the group hint")
			return
		
		var group_array: Array = group[group_name] as Array
		if not group_array:
			var msg ="The value for a group key must be an Array os Strings with the "
			msg += "property names you want to show in teh editor."
			push_error(msg)
			return
		
		custom_properties[group_name] = {}
		for index in group_array.size():
			var property: String = group_array[index] as String
			if property == null:
				push_error("All values inside the group array must be strings")
				return
			
			var editor_property_name: String = "_%s"%[property]
			custom_properties[group_name][editor_property_name] = property


func _get_original_property(property: String) -> String:
	var original_property: = ""
	for key in custom_properties:
		var value = custom_properties[key]
		if value is String:
			if key == property:
				original_property = custom_properties[key]
				break
		elif value is Dictionary:
			for group_property in value:
				if group_property == property:
					original_property = custom_properties[key][group_property]
					break
	
	return original_property


func _get_property_category() -> Dictionary:
	var dict: = {
		name = _category_name,
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY,
	}
	return dict


func _get_property_group(group_name: String) -> Dictionary:
	var dict: = {
		name = group_name,
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_GROUP,
		hint_string = "_%s_"%[group_name]
	}
	return dict


func _get_property_dict(property_name: String, original_property: String) -> Dictionary:
	var type: = typeof(node_origin.get(original_property)) 
	var hint: = PROPERTY_HINT_NONE
	var hint_string: = ""
	
	if type == TYPE_NIL:
		type = TYPE_OBJECT
		hint = PROPERTY_HINT_RESOURCE_TYPE
		hint_string = "Resource"
	
	var dict: = {
		name = "%s"%[property_name],
		type = type,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = hint,
		hint_string = hint_string
	}
	return dict


func _get_treated_property_list() ->  Array:
	var properties: = []
	if _category_name != "":
		properties.append(_get_property_category())
	
	for key in custom_properties:
		var value = custom_properties[key]
		if value is String:
			properties.append(_get_property_dict(key, value))
		elif value is Dictionary:
			properties.append(_get_property_group(key))
			for property_name in custom_properties[key]:
				properties.append(
						_get_property_dict(property_name, custom_properties[key][property_name])
				)
	
	return properties


### -----------------------------------------------------------------------------------------------
