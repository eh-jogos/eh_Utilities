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

@export var use_fade_transition := false:
	set(value):
		use_fade_transition = value
		notify_property_list_changed()

var optional_transition_data: eh_TransitionData

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func change_to_next_scene() -> void:
	if use_fade_transition:
		await eh_Transitions.play_fade_in()
	else:
		await eh_Transitions.play_transition_in(optional_transition_data)
	
	if _loader.is_loading():
		loading_wait_started.emit()
		await _loader.loading_finished
		loading_wait_finished.emit()
		if wait_for_resume:
			await transition_resumed
	
	var packed_scene: PackedScene = _loader.get_loaded_resource()
	get_tree().change_scene_to_packed(packed_scene)
	
	if use_fade_transition:
		eh_Transitions.play_fade_out()
	else:
		eh_Transitions.play_transition_out.call_deferred(optional_transition_data)


func resume_transition() -> void:
	transition_resumed.emit()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------

####################################################################################################
## Custom Inspector ################################################################################
####################################################################################################

const PROP_TRANSITION_DATA = &"optional_transition_data"

### Custom Inspector built in functions -----------------------------------------------------------

func _get_property_list() -> Array:
	var properties: = []
	
	if not use_fade_transition:
		var dict := eh_InspectorHelper.get_prop_dict(
				PROP_TRANSITION_DATA, TYPE_OBJECT, PROPERTY_HINT_RESOURCE_TYPE, "eh_TransitionData"
		)
		properties.append(dict)
	
	return properties


func _property_can_revert(property: StringName) -> bool:
	var can_revert = false
	
	match property:
		PROP_TRANSITION_DATA:
			can_revert = true
	
	return can_revert


func _property_get_revert(property: StringName):
	var value
	
	match property:
		PROP_TRANSITION_DATA:
			value = null
	
	return value

### -----------------------------------------------------------------------------------------------
