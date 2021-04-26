# A Node to help export custom resources while maintaining optional typing without having to cast.
# It doesn't solve the problem of the Huge List of Resources, but at least it allows you to have
# the variable in the editor while keeping your custom type on the script.
#
# Just instance this node as a child of a node where you declare variables that use custom typed
# resources and add a comment with "#cr-export" on the line above the variable declaration.
# 
# You can also extend this node to add your own custom comments, if you want to create different
# category sections to group different kinds of custom resources. Just make sure to extend this node
# in another one and override the `_set_default_token_and_category` method there. There's an example
# of this in the SharedVariables plugin with the class `SVEditorControls`. Or if this is something
# you want only on one particular node, you don't need to extend the script just add your custom
# comment token and category name as key and value in the exported dictionary.
tool
class_name eh_CustomEditorControls
extends Node

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------


#--- public variables - order: export > normal var > onready --------------------------------------

export var settings: Dictionary = {} 

#--- private variables - order: export > normal var > onready -------------------------------------

var _saved_data: Dictionary = {}
var _inspector_helpers: Dictionary = {}

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	for property in _saved_data:
		if property in get_parent():
			get_parent().set(property, _saved_data[property])
		else:
			push_warning("Could not find %s in %s | Path: %s"%[
					property, get_parent().name, get_parent().get_path()
			])
	
	if Engine.editor_hint:
		update_properties_to_expose()
		update_configuration_warning()
	else:
		queue_free()


func _set(property: String, value) -> bool:
	var has_handled: = false
	
	if property == "_0_saved_data":
		_saved_data = value
		has_handled = true
	else:
		var original_property = property.right(1)
		_saved_data[property.right(1)] = value
		var inspector_helper: eh_CustomInspector = _get_inspector_helper_from_property(property)
		
		if inspector_helper == null:
			return has_handled
		
		has_handled = inspector_helper._set(property, value)
	
	return has_handled


func _get(property: String):
	var to_return = null
	
	if property == "_0_saved_data":
		to_return = _saved_data
	else:
		var original_property = property.right(1)
		var inspector_helper: eh_CustomInspector = _get_inspector_helper_from_property(property)
		if inspector_helper == null:
			if _saved_data.has(original_property):
				to_return = _saved_data[original_property]
		else:
			to_return = inspector_helper._get(property)

	return to_return


func _get_property_list() -> Array:
	var properties: Array = []
	
	properties.append({
		"name": "_0_saved_data",
		"type": TYPE_DICTIONARY,
		"usage": PROPERTY_USAGE_STORAGE
	})
	
	for key in _inspector_helpers:
		var inspector_helper: eh_CustomInspector = _inspector_helpers[key] as eh_CustomInspector
		if inspector_helper != null:
			properties += inspector_helper._get_property_list()
	
	return properties


func _get_configuration_warning() -> String:
	var msg: = ""
	
	if get_parent() == null or get_parent().get_script() == null:
		msg = "This node only works as a child of another node that has a script, and that script "\
				+ "must have variables of custom types that extend from Resource and must be a tool."
	elif not get_parent().get_script().is_tool():
		msg = "Parent must be a tool script for the exported variables to work."
	
	return msg

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func update_properties_to_expose() -> void:
	_set_default_token_and_category()
	
	var unused_properties: = _saved_data.keys()
	for key in settings:
		_update_properties_for(key, unused_properties)
	
	for property in unused_properties:
		_saved_data.erase(property)
	
	property_list_changed_notify()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _set_default_token_and_category() -> void:
	settings["#cr-export"] = {
		category = "Custom Resources",
		properties = []
	}


func _get_inspector_helper_from_property(property: String) -> eh_CustomInspector:
	var inspector_helper: eh_CustomInspector = null
	
	for key in _inspector_helpers:
		inspector_helper = _inspector_helpers[key] as eh_CustomInspector
		if inspector_helper != null and inspector_helper.has_property(property):
			break
	
	return inspector_helper


func _update_properties_for(export_token: String, unused_properties: Array) -> void:
	settings[export_token].properties.clear()
	var script: GDScript = get_parent().get_script()
	_analyze_script(script, export_token, unused_properties)
	
	_create_new_inspector_helper(export_token)


func _analyze_script(script: GDScript, export_token: String, unused_properties: Array) -> void:
	var export_comment_begin = script.source_code.find(export_token)
	while export_comment_begin != -1:
		var export_comment_end = script.source_code.find("\n", export_comment_begin) 
		
		if export_comment_end == -1:
			push_error(
					"ABORTING | Couldn't find a new line after export comment."
					+ "%s must be placed directly above a variable definition"%[export_token]
			)
			break
		else:
			var next_line_break = script.source_code.find("\n", export_comment_end + "\n".length())
			var property_line: = script.source_code.substr(
					export_comment_end, next_line_break - export_comment_end
			)
			property_line = property_line.strip_edges()
			
			var property_name: = _get_property_name(property_line, export_token)
			if property_name == "":
				push_error("ABORTING | Unable to get a property name from %s"%[property_line])
				break
			
			settings[export_token].properties.append(property_name)
			if not _saved_data.has(property_name):
				_saved_data[property_name] = null
			
			if unused_properties.has(property_name):
				unused_properties.erase(property_name)
		
		export_comment_begin = script.source_code.find(export_token, export_comment_end)
	
	var base_script = script.get_base_script()
	if base_script:
		_analyze_script(base_script, export_token, unused_properties)


func _get_property_name(property_line: String, export_token: String) -> String:
	var property_name: = ""
	
	var property_name_begin: = property_line.find("var")
	if property_name_begin == -1:
		push_error("Invalid line, %s must be placed directly above a variable definition"
				%[export_token]
		)
		return property_name
	
	property_name_begin += "var".length()
	
	var property_name_end: = property_line.find(":", property_name_begin) 
	if property_name_end == -1:
		property_name_end = property_line.find("=", property_name_begin)
	if property_name_end == -1:
		property_name_end = property_line.length()
	
	property_name = property_line.substr(
			property_name_begin, property_name_end - property_name_begin
	).strip_edges()
	
	return property_name


func _create_new_inspector_helper(export_token: String) -> void:
	_inspector_helpers[export_token] = eh_CustomInspector.new(
			get_parent(), 
			settings[export_token].properties, 
			settings[export_token].category
	)

### -----------------------------------------------------------------------------------------------
