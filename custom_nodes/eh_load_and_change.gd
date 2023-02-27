@tool
class_name eh_SceneLoadAndChange
extends Node

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export_file("*.tscn") var next_scene := "":
	set(value):
		next_scene = value
		update_configuration_warnings()

#--- private variables - order: export > normal var > onready -------------------------------------

var _loader := eh_ThreadedBackgroundLoader.new()

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if not next_scene.is_empty():
		_loader.start_loading(next_scene)
	
	var parent = get_parent()
	await parent.ready
	if parent is BaseButton:
		(parent as BaseButton).pressed.connect(change_to_next_scene)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if next_scene.is_empty():
		warnings.append("next_scene path hasn't been set.")
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func change_to_next_scene() -> void:
	if _loader.is_loading():
		await _loader.loading_finished
	
	var packed_scene: PackedScene = _loader.get_loaded_resource()
	get_tree().change_scene_to_packed(packed_scene)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
