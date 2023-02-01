# Fowards any change to a Control's rect to another remote Control Node. Similar to 
# RemoteTransform2D but for Control Nodes.
@tool
class_name eh_RemoteRect
extends Node

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export var remote_path: NodePath = NodePath("") :
	set = _set_remote_path
@export var use_global_coordinates: = true

@export_group("Update", "update_")
@export var update_position: bool = true
@export var update_size: bool = true
@export var update_rotation: bool = true
@export var update_scale: bool = true
@export var update_pivot_offset: bool = true

#--- private variables - order: export > normal var > onready -------------------------------------

var _parent_control: Control
var _remote_rect: Control

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _enter_tree() -> void:
	_parent_control = get_parent() as Control
	update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var msgs: = PackedStringArray()
	
	if _parent_control == null:
		msgs.append("This node must be a child of a Control Node to work.")
	elif remote_path == NodePath(""):
		msgs.append("remote_path property must point to a valid Control Node to work")
	
	return msgs

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func update_rect() -> void:
	if not is_instance_valid(_parent_control):
		return
	
	if update_pivot_offset:
		_remote_rect.pivot_offset = _parent_control.pivot_offset
	
	if update_position:
		if use_global_coordinates:
			_remote_rect.global_position = _parent_control.global_position
		else:
			_remote_rect.position = _parent_control.position
	
	if update_size:
		_remote_rect.size = _parent_control.size
	
	if update_rotation:
		_remote_rect.rotation = _parent_control.rotation
	
	if update_scale:
		_remote_rect.scale = _parent_control.scale

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_parent_control_item_rect_changed() -> void:
	update_rect()


func _set_remote_path(value: NodePath) -> void:
	remote_path = value
	
	if not is_inside_tree():
		await self.ready
	
	if remote_path != NodePath(""):
		if _remote_rect != null:
			eh_EditorHelpers.disconnect_between(
					_parent_control.item_rect_changed, _on_parent_control_item_rect_changed
			)
			
		_remote_rect = get_node(remote_path) as Control
		if _remote_rect == null:
			remote_path = NodePath("")
			update_configuration_warnings()
			return
		
		update_rect()
		
		eh_EditorHelpers.connect_between(
				_parent_control.item_rect_changed, _on_parent_control_item_rect_changed
		)
	
	update_configuration_warnings()


### -----------------------------------------------------------------------------------------------
