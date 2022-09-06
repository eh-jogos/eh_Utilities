# Class to help create custom inspector properties, things that need more interactivity or options
# not suported by regular export hints. It is a static helper so you can just call it's functions
# anywhere.
# 
# Some tips:
# - If the properties are not appearing in the editor, make sure the script has the `tool` keyword
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
####################################################################################################
## Editor Methods ##################################################################################
####################################################################################################
#
#const CUSTOM_PROPERTIES = {
##	"": {
##		name = "",
##		backing_field = "",
##		get_method = "",
##		set_method = "",
##		type = TYPE_NIL,
##		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
##		hint = PROPERTY_HINT_NONE,
##		hint_string = "",
##	},
#}
#
#### Custom Inspector built in functions -----------------------------------------------------------
#
#func _get_property_list() -> Array:
#	var properties: = []
#	
#	for key in CUSTOM_PROPERTIES:
#		var add_property := true
#		var dict: Dictionary = CUSTOM_PROPERTIES[key]
#		if not dict.has("name"):
#			dict.name = key
#			
#		if add_property:
#			properties.append(dict)
#	
#	return properties
#
#
#func _get(property: String):
#	var value
#	
#	if property in CUSTOM_PROPERTIES: 
#		if CUSTOM_PROPERTIES[property].has("backing_field"):
#			value = get(CUSTOM_PROPERTIES[property]["backing_field"])
#		elif CUSTOM_PROPERTIES[property].has("get_method"):
#			value = call(CUSTOM_PROPERTIES[property]["get_method"])
#	
#	return value
#
#
#func _set(property: String, value) -> bool:
#	var has_handled: = false
#	
#	if property in CUSTOM_PROPERTIES :
#		if CUSTOM_PROPERTIES[property].has("backing_field"):
#			set(CUSTOM_PROPERTIES[property]["backing_field"], value)
#			has_handled = true
#		elif CUSTOM_PROPERTIES[property].has("set_method"):
#			call(CUSTOM_PROPERTIES[property]["set_method"], value)
#			has_handled = true
#	
#	return has_handled
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

static func get_enum_hint_for(
		string_array: PoolStringArray, 
		should_capitalize: = true
) -> String:
	for index in string_array.size():
		var string: String = string_array[index]
		string_array[index] = string.capitalize() if should_capitalize else string
	
	var enum_hint: = string_array.join(",")
	return enum_hint


static func add_line_break_if_not_empty(msg: String) -> String:
	if msg != "":
		msg += "\n"
	return msg

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
