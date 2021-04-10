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

var _properties_to_expose: Dictionary = {}

var _inspector_helpers: Dictionary = {}

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	update_properties_to_expose()
	
	for key in _properties_to_expose:
		for property in _properties_to_expose[key]:
			_set("_%s"%[property], get_meta(property))
	
	if not Engine.editor_hint:
		queue_free()
	
	update_configuration_warning()


func _set(property: String, value) -> bool:
	var has_handled: = false
	
	var inspector_helper: eh_CustomInspector = _get_inspector_helper_from_property(property)
	if inspector_helper == null:
		return has_handled
	
	has_handled = inspector_helper._set(property, value)
	return has_handled


func _get(property: String):
	var to_return = null
	
	var inspector_helper: eh_CustomInspector = _get_inspector_helper_from_property(property)
	if inspector_helper == null:
		return to_return
	
	to_return = inspector_helper._get(property)
	return to_return


func _get_property_list() -> Array:
	var properties: Array = []
	
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
	_properties_to_expose.clear()
	
	for key in settings:
		_update_properties_for(key, settings[key])
	
	property_list_changed_notify()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _set_default_token_and_category() -> void:
	settings["#cr-export"] = "Custom Resources"


func _get_inspector_helper_from_property(property: String) -> eh_CustomInspector:
	var inspector_helper: eh_CustomInspector = null
	
	for key in _inspector_helpers:
		inspector_helper = _inspector_helpers[key] as eh_CustomInspector
		if inspector_helper != null and inspector_helper.has_property(property):
			break
	
	return inspector_helper


func _update_properties_for(export_token: String, category_name: String) -> void:
	_properties_to_expose[export_token] = []
	var script: GDScript = get_parent().get_script()
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
			
			_properties_to_expose[export_token].append(property_name)
		
		export_comment_begin = script.source_code.find(export_token, export_comment_end)
	
	_inspector_helpers[export_token] = eh_CustomInspector.new(
			self, 
			get_parent(), 
			_properties_to_expose[export_token], 
			category_name
	)


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

### -----------------------------------------------------------------------------------------------
