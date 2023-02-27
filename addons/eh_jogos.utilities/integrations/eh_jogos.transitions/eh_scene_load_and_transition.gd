@tool
class_name eh_SceneLoadAndTransition
extends eh_SceneLoadAndChange

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

signal transition_resumed
signal wait_for_resume_changed

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export var wait_for_resume := false:
	set(value):
		var has_changed = value != wait_for_resume
		wait_for_resume = value
		if Engine.is_editor_hint() and is_inside_tree():
			wait_for_resume_changed.emit()

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func change_to_next_scene() -> void:
	await eh_Transitions.play_transition_in()
	
	if _loader.is_loading():
		loading_wait_started.emit()
		await _loader.loading_finished
		loading_wait_finished.emit()
		if wait_for_resume:
			await transition_resumed

	var packed_scene: PackedScene = _loader.get_loaded_resource()
	get_tree().change_scene_to_packed(packed_scene)
	eh_Transitions.play_transition_out.call_deferred()


func resume_transition() -> void:
	transition_resumed.emit()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
