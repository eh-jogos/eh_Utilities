# Write your doc string for this file here
tool
class_name eh_RemoteVisibility
extends Node

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

export var remote_path: NodePath = NodePath("") setget _set_remote_path

#--- private variables - order: export > normal var > onready -------------------------------------

var _remote_visibility: Node
var _parent_node: Node

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _enter_tree() -> void:
	_parent_node = get_parent()
	update_configuration_warning()


func _get_configuration_warning() -> String:
	var msg: = ""
	
	if _remote_visibility == null or not "visible" in _remote_visibility:
		msg = "Path property must point to a node that has the visible property (eye icon)."
	elif not "visible" in _parent_node:
		msg = "This node must be a child of a node that has the visible property (eye icon)."
	
	return msg

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func update_visibility() -> void:
	_remote_visibility.visible = _parent_node.visible

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _set_remote_path(value: NodePath) -> void:
	remote_path = value
	
	if not is_inside_tree():
		yield(self, "ready")
	
	if remote_path != NodePath(""):
		if _remote_visibility != null:
			if _parent_node.is_connected("visibility_changed", self, \
					"_on_remote_visibility_changed"):
				_parent_node.disconnect("visibility_changed", self, \
						"_on_remote_visibility_changed")
		
		_remote_visibility = get_node(remote_path)
		update_configuration_warning()
		if not "visible" in _remote_visibility:
			remote_path = NodePath("")
			_remote_visibility = null
			return
		
		update_visibility()
		
		if not _parent_node.is_connected("visibility_changed", self, \
				"_on_remote_visibility_changed"):
			_parent_node.connect("visibility_changed", self, \
					"_on_remote_visibility_changed")


func _on_remote_visibility_changed() -> void:
	update_visibility()

### -----------------------------------------------------------------------------------------------
