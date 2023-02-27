@tool
class_name eh_SceneLoadAndTransition
extends eh_SceneLoadAndChange

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func change_to_next_scene() -> void:
	if _loader.is_loading():
		await _loader.loading_finished
	
	var packed_scene: PackedScene = _loader.get_loaded_resource()
	eh_Transitions.transition_to_packed(packed_scene)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
