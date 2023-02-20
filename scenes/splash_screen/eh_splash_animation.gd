@tool
class_name eh_SplashAnimation
extends Control

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

signal splash_animation_finished
signal splash_animation_skip_reached

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const ANIM_FADE_IN = &"fade_in"
const ANIM_DURATION = &"duration"
const ANIM_FADE_OUT = &"fade_out"

#--- public variables - order: export > normal var > onready --------------------------------------

@export_node_path("AnimationPlayer") var path_animator := ^"AnimationPlayer":
	set(value):
		path_animator = value
		if Engine.is_editor_hint() and is_inside_tree():
			_animator = get_node(path_animator)
			notify_property_list_changed()
			update_configuration_warnings()

@export var is_skippable := false:
	set(value):
		is_skippable = value
		notify_property_list_changed()
		update_configuration_warnings()

#--- private variables - order: export > normal var > onready -------------------------------------

var _main_animation := &"main"
var _is_skipping := false

@onready var _animator := get_node(path_animator) as AnimationPlayer

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if eh_EditorHelpers.is_standalone_run(self):
		_standalone_test()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if not _animator:
		warnings.append(
				"Invalid _path_animator: %s .Could not find AnimationPlayer node."%[path_animator]
		)
	elif is_skippable:
		if not _animator.has_animation(ANIM_FADE_IN):
			warnings.append("Skippable splashes require an animation named '%s'."%[ANIM_FADE_IN])
		
		if not _animator.has_animation(ANIM_DURATION):
			warnings.append("Skippable splashes require an animation named '%s'."%[ANIM_DURATION])
		
		if not _animator.has_animation(ANIM_FADE_OUT):
			warnings.append("Skippable splashes require an animation named '%s'."%[ANIM_FADE_OUT])
		
	elif not is_skippable and not _animator.has_animation(_main_animation):
		warnings.append("Could not find '%s' animation in AnimationPlayer."%[_main_animation])
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func play_splash_animation() -> void:
	var animation := ANIM_FADE_IN if is_skippable else _main_animation
	_animator.play(animation)


func skip_splash_animation() -> void:
	if not is_skippable or _is_skipping or _animator.assigned_animation == ANIM_FADE_OUT:
		return
	
	_is_skipping = true
	if _animator.assigned_animation == ANIM_FADE_IN:
		await splash_animation_skip_reached
	
	_play_fade_out_animation()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _standalone_test() -> void:
	await get_tree().create_timer(1.0).timeout
	play_splash_animation()


func _play_fade_out_animation() -> void:
	_animator.play(ANIM_FADE_OUT)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		_main_animation, ANIM_FADE_OUT:
			splash_animation_finished.emit()
			_is_skipping = false
		ANIM_FADE_IN:
			_animator.play(ANIM_DURATION)
			splash_animation_skip_reached.emit()
		ANIM_DURATION:
			_play_fade_out_animation()

### -----------------------------------------------------------------------------------------------

###################################################################################################
# Custom Inspector ################################################################################
###################################################################################################

const PROP_MAIN_ANIMATION = &"main_animation"

### Custom Inspector built in functions -----------------------------------------------------------

func _get_property_list() -> Array:
	var properties: = []
	
	var main_animation_dict := {
			name = PROP_MAIN_ANIMATION,
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			hint = PROPERTY_HINT_NONE,
			hint_string = "",
	}
	
	if is_skippable:
		main_animation_dict.usage = PROPERTY_USAGE_STORAGE
	else:
		if is_inside_tree() and _animator != null:
			var animations_list := _animator.get_animation_list()
			main_animation_dict.hint = PROPERTY_HINT_ENUM
			main_animation_dict.hint_string = \
					eh_InspectorHelper.get_enum_hint_for(animations_list, false)
	
	properties.append(main_animation_dict)
	
	return properties


func _get(property: StringName):
	var value
	
	match property:
		PROP_MAIN_ANIMATION:
			value = _main_animation
	
	return value


func _set(property: StringName, value) -> bool:
	var has_handled: = false
	
	match property:
		PROP_MAIN_ANIMATION:
			_main_animation = value
	
	return has_handled

### -----------------------------------------------------------------------------------------------
