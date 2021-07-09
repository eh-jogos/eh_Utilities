# Fowards any change to a Control's rect to another remote Control Node. Similar to 
# RemoteTransform2D but for Control Nodes.
tool
class_name eh_RemoteRect
extends Node

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

export var remote_path: NodePath = NodePath("") setget _set_remote_path
export var use_global_coordinates: = true

var update_position: bool = true
var update_size: bool = true
var update_rotation: bool = true
var update_scale: bool = true
var update_pivot_offset: bool = true

#--- private variables - order: export > normal var > onready -------------------------------------

var _parent_control: Control
var _remote_rect: Control

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _enter_tree() -> void:
	_parent_control = get_parent() as Control
	update_configuration_warning()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func update_rect() -> void:
	if _parent_control == null:
		return
	
	if update_pivot_offset:
		_remote_rect.rect_pivot_offset = _parent_control.rect_pivot_offset
	
	if update_position:
		if use_global_coordinates:
			_remote_rect.rect_global_position = _parent_control.rect_global_position
		else:
			_remote_rect.rect_position = _parent_control.rect_position
	
	if update_size:
		_remote_rect.rect_size = _parent_control.rect_size
	
	if update_rotation:
		_remote_rect.rect_rotation = _parent_control.rect_rotation
	
	if update_scale:
		_remote_rect.rect_scale = _parent_control.rect_scale

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_parent_control_item_rect_changed() -> void:
	update_rect()


func _set_remote_path(value: NodePath) -> void:
	remote_path = value
	
	if not is_inside_tree():
		yield(self, "ready")
	
	if remote_path != NodePath(""):
		if _remote_rect != null:
			if _parent_control.is_connected("item_rect_changed", self, \
					"_on_parent_control_item_rect_changed"):
				_parent_control.disconnect("item_rect_changed", self, \
						"_on_parent_control_item_rect_changed")
			
		_remote_rect = get_node(remote_path) as Control
		if _remote_rect == null:
			remote_path = NodePath("")
			update_configuration_warning()
			return
		
		update_rect()
		
		if not _parent_control.is_connected("item_rect_changed", self, \
				"_on_parent_control_item_rect_changed"):
			_parent_control.connect("item_rect_changed", self, \
					"_on_parent_control_item_rect_changed")
	
	update_configuration_warning()


### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

var _custom_inspector: eh_CustomInspector = eh_CustomInspector.new(
	self,
	[
		{"update": [
			"update_position", 
			"update_size", 
			"update_rotation", 
			"update_scale", 
			"update_pivot_offset"
		]}
	],
	""
)

### Editor Methods --------------------------------------------------------------------------------

func _get_property_list() -> Array:
	var properties: = _custom_inspector._get_property_list()
	return properties


func _get(property: String):
	return _custom_inspector._get(property)


func _set(property: String, value) -> bool:
	var has_handled: = _custom_inspector._set(property, value)
	if has_handled:
		update_configuration_warning()
		property_list_changed_notify()
	return has_handled


func _get_configuration_warning() -> String:
	var msg: = ""
	
	if _parent_control == null:
		msg = "This node must be a child of a Control Node to work."
	elif remote_path == NodePath(""):
		msg = "Path property must point to a valid Control Node to work"
	
	return msg

### -----------------------------------------------------------------------------------------------
