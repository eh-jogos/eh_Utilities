# Based on GDQuest's State
class_name eh_State
extends Node

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

signal state_finished

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

# Array of Dicts in the format: {source: Object, signal_name: String, method_name: String}
var _incoming_connections: Array

onready var _state_machine: = _get_state_machine(self)

onready var _parent = get_parent()

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if eh_EditorHelpers.is_editor():
		eh_EditorHelpers.disable_all_processing(self)
		return
	
	_incoming_connections = get_incoming_connections()
	_disconnect_signals()
	yield(owner, "ready")


func get_class() -> String:
	return "eh_State"


func is_class(p_class: String) -> bool:
	return p_class == get_class() or .is_class(p_class)

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(_msg: = {}) -> void:
	_connect_signals()


func unhandled_input(_event: InputEvent) -> void:
	return


func process(_delta: float) -> void:
	return


func physics_process(_delta: float) -> void:
	return


func exit() -> void:
	_disconnect_signals()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _is_active_state() -> bool:
	if eh_EditorHelpers.is_editor():
		return false
	
	var is_active: bool = _state_machine.state == self
	
	if not is_active:
		var active_nodepath: NodePath = _state_machine.get_path_to(_state_machine.state)
		for index in active_nodepath.get_name_count():
			var node_name = active_nodepath.get_name(index)
			is_active = node_name == name
			if is_active:
				break
	
	return is_active


func _get_state_machine(node: Node) -> Node:
	if eh_EditorHelpers.is_editor():
		return null
	
	if node == null:
		push_error("Couldn't find a StateMachine in this scene tree. State name: %s"%[name])
	elif not node.is_class("StateMachine"):
		node = _get_state_machine(node.get_parent())
	
	return node 


func _connect_signals() -> void:
	for dict in _incoming_connections:
		if dict.source == null or not is_instance_valid(dict.source):
			push_error("Invalid source in dict: %s"%[dict])
			continue
		
		eh_EditorHelpers.connect_between(dict.source, dict.signal_name, self, dict.method_name)


func _disconnect_signals() -> void:
	for dict in _incoming_connections:
		if dict.source == null or not is_instance_valid(dict.source):
			push_error("Invalid source in dict: %s"%[dict])
			continue
		
		eh_EditorHelpers.disconnect_between(dict.source, dict.signal_name, self, dict.method_name)

### -----------------------------------------------------------------------------------------------
