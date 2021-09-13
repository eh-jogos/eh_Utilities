# Based on GDQuest's State
class_name State
extends Node

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const CLASS_STRING = "State"

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

onready var _state_machine: = _get_state_machine(self)

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if eh_EditorHelpers.is_editor():
		eh_EditorHelpers.disable_all_processing(self)
		return
	yield(owner, "ready")


func is_class(p_class: String) -> bool:
	return p_class == CLASS_STRING or .is_class(p_class)


func get_class() -> String:
	return CLASS_STRING

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func enter(_msg: = {}) -> void:
	return


func unhandled_input(_event: InputEvent) -> void:
	return


func process(_delta: float) -> void:
	return


func physics_process(_delta: float) -> void:
	return


func exit() -> void:
	return

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _get_state_machine(node: Node) -> Node:
	if eh_EditorHelpers.is_editor():
		return node
	
	if node == null:
		push_error("Couldn't find a StateMachine in this scene tree. State name: %s"%[name])
	elif not node.is_class("StateMachine"):
		node = _get_state_machine(node.get_parent())
	
	return node 

### -----------------------------------------------------------------------------------------------
