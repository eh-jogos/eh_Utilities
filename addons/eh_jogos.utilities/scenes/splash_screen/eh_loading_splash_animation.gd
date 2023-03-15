@tool
class_name eh_SplashAnimationLoading
extends eh_SplashAnimation

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

var loader: eh_ThreadedBackgroundLoader = null

#--- private variables - order: export > normal var > onready -------------------------------------

var _loading_animation := ""

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _play_fade_out_animation() -> void:
	if loader.is_loading():
		_animator.play(_loading_animation)
		await loader.loading_finished
	
	_animator.play(ANIM_FADE_OUT)

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

const PROP_LOADING_ANIMATION = &"loading_animation"

### Custom Inspector built in functions -----------------------------------------------------------

func _get_property_list() -> Array:
	var properties: = []
	var loading_animation_dict := {
			name = PROP_LOADING_ANIMATION,
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
			hint_string = "",
	}
	
	if is_inside_tree() and _animator != null: 
		var animations_list := _animator.get_animation_list()
		loading_animation_dict.hint = PROPERTY_HINT_ENUM
		loading_animation_dict.hint_string = \
				eh_InspectorHelper.get_enum_hint_for(animations_list, false)
	
	properties.append(loading_animation_dict)
	
	return properties


func _get(property: StringName):
	var value
	
	match property:
		PROP_LOADING_ANIMATION:
			value = _loading_animation
	
	return value


func _set(property: StringName, value) -> bool:
	var has_handled: = true
	
	match property:
		PROP_LOADING_ANIMATION:
			_loading_animation = value
		_:
			has_handled = false
	
	return has_handled

### -----------------------------------------------------------------------------------------------
