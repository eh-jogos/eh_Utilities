# Based on GDQuest StateMachine but with some modifications in case it's extended to a tool script.
# Which I sometimes do to add some debugging shared variables
class_name eh_StateMachine
extends Node

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

signal transitioned(state_path)

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const CLASS_STRING = "StateMachine"

#--- public variables - order: export > normal var > onready --------------------------------------

export var initial_state: NodePath = NodePath("")

var is_active: bool = true setget _set_is_active

var state: eh_State = null

#--- private variables - order: export > normal var > onready -------------------------------------

var _state_name: String = ""

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if eh_EditorHelpers.is_editor():
		eh_EditorHelpers.disable_all_processing(self)
		return
	
	yield(owner, "ready")
	_set_state(get_node(initial_state))
	state.enter()
	_state_name = state.name
	emit_signal("transitioned", self.get_path_to(state))


func _unhandled_input(event: InputEvent) -> void:
	state.unhandled_input(event)


func _process(delta: float) -> void:
	state.process(delta)


func _physics_process(delta: float) -> void:
	state.physics_process(delta)


func get_class() -> String:
	return "StateMachine"


func is_class(p_class: String) -> bool:
	return p_class == get_class() or .is_class(p_class)

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func transition_to(target_state_path: String, msg: = {}) -> void:
	if not has_node(target_state_path):
		return
	
	var target_state = get_node(target_state_path)
	state.exit()
	_set_state(target_state)
	state.enter(msg)
	emit_signal("transitioned", target_state_path)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _set_is_active(value: bool) -> void:
	is_active = value
	set_process_unhandled_input(is_active)
	set_process(is_active)
	set_physics_process(is_active)


func _set_state(value: eh_State) -> void:
	state = value
	_state_name = state.name

### -----------------------------------------------------------------------------------------------
