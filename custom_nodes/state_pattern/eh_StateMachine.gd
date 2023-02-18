@tool
class_name eh_StateMachine
extends Node

## Based on GDQuest's StateMachine but with some modifications to make it a 
## [code]@tool[/code] script and convert to GDScript 2.0.
##
## Generic State Machine that can be used for handling States as nodes. It has a signal to notify 
## about transitions.
## [br][br]
## It also has a read-only [member state_name] property to help with debugging or checking 
## current state.

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

## Emitted whenever there is a state transtion.
signal transitioned(state_path)

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

## Value returned by [member state_name] when [member state] is [code]null[/code].
const INVALID_NODEPATH = ^"invalid"

#--- public variables - order: export > normal var > onready --------------------------------------

## [NodePath] to initial state, should be defined in the inspector.
@export_node_path("eh_State") var initial_state := NodePath(""):
	set(value):
		initial_state = value
		update_configuration_warnings()

var is_active: bool = true:
	set(value):
		is_active = value
		set_process_unhandled_input(is_active)
		set_process(is_active)
		set_physics_process(is_active)

## Current state.
var state: eh_State = null:
	set(value):
		state = value
		if is_inside_tree() and is_instance_valid(state):
			state_name = get_path_to(state)
## Current state name.
var state_name: NodePath = INVALID_NODEPATH

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if Engine.is_editor_hint():
		eh_EditorHelpers.disable_all_processing(self)
		return
	
	if is_instance_valid(owner):
		await owner.ready
	
	state = get_node(initial_state) as eh_State
	state.enter()
	emit_signal("transitioned", self.get_path_to(state))


func _unhandled_input(event: InputEvent) -> void:
	state.unhandled_input(event)


func _process(delta: float) -> void:
	state.process(delta)


func _physics_process(delta: float) -> void:
	state.physics_process(delta)

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

## Takes a [NodePath] to the next state node, and transitions to it. Can optionally receive a 
## dictionary to be passed to the [method QuiverState.enter] method of the new state.[br]
## Note that the [NodePath] passed in must be relative to the StateMachine node.
func transition_to(target_state_path: String, msg: = {}) -> void:
	if not is_active: 
		return
	elif not has_node(target_state_path):
		push_error("Could not find state in path: %s"%[target_state_path])
		return
	
	var target_state = get_node(target_state_path)
	state.exit()
	state = target_state
	state.enter(msg)
	emit_signal("transitioned", target_state_path)


func stop_all_processing() -> void:
	set_process_unhandled_input(false)
	set_process(false)
	set_physics_process(false)


func resume_all_processing() -> void:
	set_process_unhandled_input(true)
	set_process(true)
	set_physics_process(true)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
