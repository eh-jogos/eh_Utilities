class_name eh_State
extends Node

## Based on GDQuest's State, but converted to GDScript 2.0 and modified with a few extra features
## like supporting signal connections made through the editor.

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

## Can be emitted by user when a state finishes it's task. Useful for Sequence States.
signal state_finished

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

# Array of Dicts in the format: {source: Object, signal_name: String, method_name: String}
var _incoming_connections: Array

var _state_machine: eh_StateMachine = null

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _enter_tree() -> void:
	_state_machine = _get_state_machine(self) as eh_StateMachine
#	print("_state_machine: %s"%[_state_machine])
	update_configuration_warnings()


func _ready() -> void:
	if Engine.is_editor_hint():
		eh_EditorHelpers.disable_all_processing(self)
		return
	
	_incoming_connections = get_incoming_connections()
	_disconnect_signals()
	await owner.ready

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

## Executed when the state machines transitions into this state. [br]
## To be overriden by scripts that inherit this class, but be careful to preserve the call to 
## [method _connect_signals] if you are connecting any signals to the state using the editor.
func enter(_msg: = {}) -> void:
	_connect_signals()

## Handles input events the state machine defers to this state. Equivalent of 
## [method Node._unhandeled_input]. [br]
## Virtual function to be overriden by inheriting classes, if needed.
func unhandled_input(_event: InputEvent) -> void:
	return

## Handles processing the state machine defers to this state. Equivalent of 
## [method Node._process].[br]
## Virtual function to be overriden by inheriting classes, if needed.
func process(_delta: float) -> void:
	return

## Handles physics processing the state machine defers to this state. Equivalent of 
## [method Node._physics_process].[br]
## Virtual function to be overriden by inheriting classes, if needed.
func physics_process(_delta: float) -> void:
	return

## Executed when the state machine transitions out of this state. [br]
## To be overriden by scripts that inherit this class, but be careful to preserve the call to 
## [method _disconnect_signals] if you are connecting any signals to the state using the editor.
func exit() -> void:
	_disconnect_signals()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _is_active_state() -> bool:
	if Engine.is_editor_hint():
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


func _get_state_machine(node: Node) -> eh_StateMachine:
	if Engine.is_editor_hint():
		return null
	
	if node == null:
		push_error("Couldn't find a StateMachine in this scene tree. State name: %s"%[name])
	elif not node is eh_StateMachine:
		node = _get_state_machine(node.get_parent())
	
	return node as eh_StateMachine


## Connects all signals saved in [member _incoming_connection]. Usually called in the 
## [method enter] method.
func _connect_signals() -> void:
	for dict in _incoming_connections:
		if not dict.has_all(["signal", "callable", "flags"]):
			push_error("Invalid source in dict: %s"%[dict])
			continue
		
		dict["signal"].connect(dict["callable"], dict.flags)


## Disconnects all signals saved in [member _incoming_connection]. Usually called in the 
## [method exit] method.
func _disconnect_signals() -> void:
	for dict in _incoming_connections:
		if not dict.has_all(["signal", "callable"]):
			push_error("Invalid source in dict: %s"%[dict])
			continue
		
		dict["signal"].disconnect(dict["callable"])

### -----------------------------------------------------------------------------------------------
