@tool
class_name eh_SceneLoadAndChange
extends Node

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

signal loading_progressed(p_progress: float)
signal loading_wait_started
signal loading_wait_finished

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export_file("*.tscn") var next_scene := "":
	set(value):
		next_scene = value
		update_configuration_warnings()

#--- private variables - order: export > normal var > onready -------------------------------------

@export_group("Debug Options", "_debug_")
@export var _debug_force_load_time := 0

var _loader := eh_ThreadedBackgroundLoader.new()

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if not next_scene.is_empty():
		if OS.has_feature("debug"):
			_loader.start_loading(next_scene, _debug_force_load_time)
		else:
			_loader.start_loading(next_scene)
		
		_loader.loading_progressed.connect(_report_loading_progress)
	
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
		loading_wait_started.emit()
		await _loader.loading_finished
		loading_wait_finished.emit()
	
	var packed_scene: PackedScene = _loader.get_loaded_resource()
	get_tree().change_scene_to_packed(packed_scene)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _report_loading_progress(value: float) -> void:
	loading_progressed.emit(value)

### -----------------------------------------------------------------------------------------------
