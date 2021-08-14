# Class to help create custom inspector properties, things that need more interactivity or options
# not suported by regular export hints. It is a static helper so you can just call it's functions
# anywhere.
# 
# Some tips:
# - If the properties are not appearing in the editor, make sure the script has teh `tool` keyword
# - Be careful that the script isn't doing anything you don't want to happen in the editor in 
# default engine functions like `_ready()` and the process and input functions. Checking for 
# `Engine.editor_hint` might help with that.
# - Because we are using `tool`, if the script has an error, and you save, after you fix the error 
# and save again, all the values you had set in the scene are lost. To avoid that:
#   - close the scene without saving before you fix the script. This will only affect opened scenes.
#   - If you're using git, try to commit the file or at least stage it before doing anything 
# dangerous in sensitive scripts so that you can have an easy way to restore lost values.
# - If your properties have the same name as your member variables, `_set` and `_get` will never 
# get called for them, but if you need them to anything other then just a simple set or get, you'll 
# need to define setters and getters with the `setget`keyword for them.
# - You don't have to use the same names for properties as the member variable, and then you'll need 
# to use `_set` and `_get` to define what will this properties do. So you can use member variables 
# with different names as backing fields, or even set/get the values into Arrays or Dictionaries or 
# anything else.
#
# Example snippet to copy-paste:
#
###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################
#
#### Editor Methods --------------------------------------------------------------------------------
#
#func _get_property_list() -> Array:
#	var properties: = []
#
#	return properties
#
#
#func _get(property: String):
#	var to_return = null
#
#	return to_return
#
#
#func _set(property: String, value) -> bool:
#	var has_handled: = false
#
#	return has_handled
#
#
#func _get_configuration_warning() -> String:
#	var msg: = ""
#
#	return msg
#
#### -----------------------------------------------------------------------------------------------

class_name eh_InspectorHelper
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

static func get_category_dict(category_name: String) -> Dictionary:
	return {
		name = category_name,
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY,
	}


static func get_group_dict(group_name: String, group_prefix: String) -> Dictionary:
	return {
			name = group_name,
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_GROUP,
			hint_string = group_prefix,
	}


static func get_property_dict_for(
			p_name: String, 
			p_type: int, 
			p_usage: = PROPERTY_USAGE_DEFAULT, 
			p_hint: = -1, 
			p_hint_string: = ""
	) -> Dictionary:
	return {
		name = p_name,
		type = p_type,
		usage = p_usage,
		hint = _get_hint_for(p_type) if p_hint == -1 else p_hint,
		hint_string = _get_hint_string_for(p_type) if p_hint_string == "" else p_hint_string
	}


static func get_enum_hint_for(string_array: PoolStringArray) -> String:
	for index in string_array.size():
		var string: String = string_array[index]
		string_array[index] = string.capitalize()
	
	var enum_hint: = string_array.join(",")
	return enum_hint

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

static func _get_hint_for(p_type: int) -> int:
	var hint: int = PROPERTY_HINT_NONE
	
	match p_type:
		TYPE_BOOL, TYPE_NODE_PATH, TYPE_VECTOR2:
			hint = PROPERTY_HINT_NONE
	
	return hint


static func _get_hint_string_for(p_type: int) -> String:
	var hint_string: = ""
	
	match p_type:
		TYPE_BOOL, TYPE_NODE_PATH:
			hint_string = ""
	
	return hint_string

### -----------------------------------------------------------------------------------------------
