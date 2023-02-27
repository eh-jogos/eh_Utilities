# Write your doc string for this file here
@tool
class_name eh_RemoteVisibility
extends Node

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export var remote_path: NodePath = NodePath("") :
	set = _set_remote_path

#--- private variables - order: export > normal var > onready -------------------------------------

var _remote_visibility: Node
var _parent_node: CanvasItem

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _enter_tree() -> void:
	_parent_node = get_parent()
	update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var msgs: = PackedStringArray()
	
	if _remote_visibility == null or not "visible" in _remote_visibility:
		msgs.append(
				"remote_path property must point to a node that has the visible property (eye icon)."
		)
	elif not "visible" in _parent_node:
		msgs.append(
				"This node must be a child of a node that has the visible property (eye icon)."
		)
	
	return msgs

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func update_visibility() -> void:
	_remote_visibility.visible = _parent_node.visible

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _set_remote_path(value: NodePath) -> void:
	remote_path = value
	
	if not is_inside_tree():
		await self.ready
	
	eh_EditorHelpers.disconnect_between(
			_parent_node.visibility_changed, _on_remote_visibility_changed
	)
	if remote_path != NodePath(""):
		if _remote_visibility != null:
			eh_EditorHelpers.disconnect_between(
					_parent_node.visibility_changed, _on_remote_visibility_changed
			)
		
		_remote_visibility = get_node(remote_path)
		update_configuration_warnings()
		if not "visible" in _remote_visibility:
			remote_path = NodePath("")
			_remote_visibility = null
			return
		
		update_visibility()
		
		eh_EditorHelpers.connect_between(
				_parent_node.visibility_changed, _on_remote_visibility_changed
		)


func _on_remote_visibility_changed() -> void:
	update_visibility()

### -----------------------------------------------------------------------------------------------
