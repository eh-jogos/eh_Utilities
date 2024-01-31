
class_name eh_InspectorHelper
extends RefCounted

## Class to help create custom inspector properties, things that need more interactivity or options
## not suported by regular export hints. It is a static helper so you can just call it's functions
## anywhere.
## 
## Some tips:
## - If the properties are not appearing in the editor, make sure the script has the `@tool` annotation
## - Be careful that the script isn't doing anything you don't want to happen in the editor in 
## default engine functions like `_ready()` and the process and input functions. Checking for 
## `Engine.editor_hint` might help with that.
## - Because we are using `@tool`, if the script has an error, and you save, after you fix the error 
## and save again, all the values you had set in the scene are lost. To avoid that:
##   - close the scene without saving before you fix the script. This will only affect opened scenes.
##   - If you're using git, try to commit the file or at least stage it before doing anything 
## dangerous in sensitive scripts so that you can have an easy way to restore lost values.
## - If your properties have the same name as your member variables, `_set` and `_get` will never 
## get called for them, but if you need them to anything other then just a simple set or get, you'll 
## need to define setters and getters for them.
## - You don't have to use the same names for properties as the member variable, and then you'll need 
## to use `_set` and `_get` to define what will this properties do. So you can use member variables 
## with different names as backing fields, or even set/get the values into Arrays or Dictionaries or 
## anything else.
##
## There is a code snippets at the end of the script to help setup advanced exports.

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

static func get_prop_dict(
		p_name: StringName, 
		p_type: int, 
		p_hint := PROPERTY_HINT_NONE, 
		p_hint_string := "",
		p_usage := PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
) -> Dictionary:
	return {
			name = p_name,
			type = p_type,
			usage = p_usage,
			hint = p_hint,
			hint_string = p_hint_string,
	}


static func get_group_dict(p_name: StringName, p_hint_string: String) -> Dictionary:
	return get_prop_dict(p_name, TYPE_NIL, PROPERTY_HINT_NONE, p_hint_string, PROPERTY_USAGE_GROUP)


static func get_storage_prop_dict(p_name: StringName, p_type: int) -> Dictionary:
	return get_prop_dict(p_name, p_type, PROPERTY_HINT_NONE, "", PROPERTY_USAGE_STORAGE)


static func get_enum_hint_for(
		string_array: PackedStringArray, 
		should_capitalize: = true
) -> String:
	for index in string_array.size():
		var string: String = string_array[index]
		string_array[index] = string.capitalize() if should_capitalize else string
	
	var enum_hint: = ",".join(string_array)
	return enum_hint


static func add_line_break_if_not_empty(msg: String) -> String:
	if msg != "":
		msg += "\n"
	return msg

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

### Code Snippets ---------------------------------------------------------------------------------

####################################################################################################
## Custom Inspector ################################################################################
####################################################################################################
#
#### Custom Inspector built in functions -----------------------------------------------------------
#
#func _get_property_list() -> Array:
#	var properties: = []
#	
#	return properties
#
#
#func _property_can_revert(property: StringName) -> bool:
#	var can_revert = false
#	
#	return can_revert
#
#
#func _property_get_revert(property: StringName):
#	var value
#	
#	return value
#
#
#func _get(property: StringName):
#	var value
#	
#	match property:
#		_:
#			pass
#	
#	return value
#
#
#func _set(property: StringName, value) -> bool:
#	var has_handled: = true
#	
#	match property:
#		_:
#			has_handled = false
#	
#	return has_handled
#
#### -----------------------------------------------------------------------------------------------
