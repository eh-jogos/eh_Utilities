@tool
extends "res://addons/eh_jogos.utilities/scenes/splash_screen/eh_splash_screen.gd"

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export var use_fade_out := true:
	set(value):
		use_fade_out = value
		notify_property_list_changed()
var optional_transition_data: eh_TransitionData

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	super()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _change_to_next_scene() -> void:
	if _loader.is_loading():
		await _loader.loading_finished
	
	await eh_Transitions.cut_to_color()
	var packed_scene: PackedScene = _loader.get_loaded_resource()
	if use_fade_out:
		eh_Transitions.play_fade_out.call_deferred()
	else:
		eh_Transitions.play_transition_out(optional_transition_data)
	get_tree().change_scene_to_packed(packed_scene)

### -----------------------------------------------------------------------------------------------

####################################################################################################
## Custom Inspector ################################################################################
####################################################################################################

const PROP_TRANSITION_DATA = &"optional_transition_data"

### Custom Inspector built in functions -----------------------------------------------------------

func _get_property_list() -> Array:
	var properties: = []
	
	if not use_fade_out:
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
