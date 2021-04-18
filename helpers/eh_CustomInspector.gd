# Class to help export custom resources as properties into the inspector while maintaining the
# variables in your code with their respective custom types. Used by the node 
# `eh_CustomEditorControls` to make the process fully automated. 
#
# But you can use this directly as well if you wish, by instancing it in any script and then 
# delegating the `_get_property_list`, `_get` and `_set` methods to it.  Then during `_ready()` 
# make sure to call `set_source_properties` so that the values that are saved in the properties 
# shown in the editor are set back to the variables in the script. That's basically what
# `eh_CustinEditorControls take care of for you.
class_name eh_CustomInspector
extends Reference

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

var custom_properties: = {}
var node_origin: Node
var node_inspector_control: Node

#--- private variables - order: export > normal var > onready -------------------------------------

var _category_name: String = ""

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _init(p_inspector: Node, p_origin: Node, properties: Array, category: String = "") -> void:
	node_inspector_control = p_inspector
	node_origin = p_origin
	_category_name = category
	for property in properties:
		var key: String = "_%s"%[property]
		custom_properties[key] = property


func _set(property: String, value) -> bool:
	var has_handled: = false
	
	if custom_properties.has(property):
		node_origin.set(custom_properties[property], value)
		node_inspector_control.set_meta(
				custom_properties[property], 
				value
		)
		has_handled = true
	
	return has_handled


func _get(property: String):
	var to_return = null
	if custom_properties.has(property):
		if node_inspector_control.has_meta(custom_properties[property]):
			to_return = node_inspector_control.get_meta(custom_properties[property])
		else:
			to_return = node_origin.get(custom_properties[property])
	
	return to_return


func _get_property_list() -> Array:
	var properties: = _get_properties_for(custom_properties.keys())
	return properties

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func has_property(p_property: String) -> bool:
	return custom_properties.has(p_property)


func set_source_properties() -> void:
	for meta_property in custom_properties:
		var original_property = custom_properties[meta_property]
		_set(meta_property, node_inspector_control.get_meta(original_property))

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _get_property_category() -> Dictionary:
	var dict = {
		name = _category_name,
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY,
	}
	return dict


func _get_property_dict(property_name: String) -> Dictionary:
	var dict = {
		name = "%s"%[property_name],
		type = TYPE_OBJECT,
		usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		hint = PROPERTY_HINT_RESOURCE_TYPE,
		hint_string = "Resource"
	}
	return dict


func _get_properties_for(names: PoolStringArray) ->  Array:
	var properties: = []
	if _category_name != "":
		properties.append(_get_property_category())
	
	for name in names:
		properties.append(_get_property_dict(name))
	return properties


### -----------------------------------------------------------------------------------------------
