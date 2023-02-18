# Write your doc string for this file here
class_name eh_ThreadedBackgroundLoader
extends RefCounted

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

signal loading_progressed(progress_value)
signal loading_finished(loaded_resource)
signal loading_safely_aborted

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _path_to_load := "" :
	set = set_path_to_load

var _loaded_resource: Resource = null
var _is_aborting_load := false
var _has_finished_loading := false

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func set_path_to_load(value: String) -> void:
	if not _path_to_load.is_empty() and not _has_finished_loading:
		var msg = "Can't set path to load while another path is being loaded. "\
				+ "Abort current loading first"
		push_error(msg)
		return
	
	if value.is_empty():
		_path_to_load = value
		return
	
	if ResourceLoader.exists(value):
		if not _path_to_load.is_empty():
			var msg = (
					"Path given is different from previously set but not loaded path."
					+"%s will overwrite the current path %s"%[
						value, _path_to_load
					]
			)
			push_warning(msg)
		
		_path_to_load = value
	else:
		push_warning("%s is an invalid resource path.")


func get_path_to_load() -> String:
	return _path_to_load


func get_total_stages() -> int:
	var value := 0
	
	if not _path_to_load.is_empty():
		value = ResourceLoader.get_dependencies(_path_to_load).size()
	
	return value


func has_finished() -> bool:
	return _has_finished_loading


func is_loading() -> bool:
	var status := ResourceLoader.load_threaded_get_status(_path_to_load)
	return status == ResourceLoader.THREAD_LOAD_IN_PROGRESS


func start_loading(p_path: String = "") -> void:
	if _is_aborting_load:
		await self.loading_safely_aborted
	
	if is_loading():
		push_error("This Loader is already busy loading: %s"%[_path_to_load])
		return
	
	if not p_path.is_empty():
		set_path_to_load(p_path)
	
	if _path_to_load.is_empty():
		if p_path.is_empty():
			push_error(
					"You need to provide a valid resource path to load." 
					+"Either by sending it as an argument to start_loading or by setting "
					+"it before hand with set_path_to_load."
			)
		return
	
	clear_loaded_resource()
	ResourceLoader.load_threaded_request(_path_to_load, "", false, ResourceLoader.CACHE_MODE_REUSE)
	_process_progress()


func get_loaded_resource() -> Resource:
	return _loaded_resource


func clear_loaded_resource() -> void:
	if is_loading():
		push_error("Can't clear loaded resource while still loading. Use abort_loading instead.")
		return
	
	_loaded_resource = null
	_has_finished_loading = false


func abort_loading() -> void:
	if is_loading():
		_is_aborting_load = true

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _process_progress() -> void:
	var tree: = Engine.get_main_loop() as SceneTree
	
	var progress_array := []
	var status := ResourceLoader.load_threaded_get_status(_path_to_load, progress_array)
	while status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		var progress := progress_array[0] as float
		emit_signal("loading_progressed", progress)
		
		await tree.process_frame 
		
		if _is_aborting_load:
			status = ERR_PRINTER_ON_FIRE
			break
		else:
			status = ResourceLoader.load_threaded_get_status(_path_to_load, progress_array)
	
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		_loaded_resource = ResourceLoader.load_threaded_get(_path_to_load)
		emit_signal("loading_progressed", 1.0)
		call_deferred("_on_thread_finished")
	elif status == ERR_PRINTER_ON_FIRE:
		call_deferred("_on_loading_thread_aborted")
	else:
		push_error("Something went wrong when trying to load %s. Error Code: %s"%[
				_path_to_load, status
		])
		call_deferred("_on_thread_finished", true)


func _on_thread_finished(has_failed := false) -> void:
	_has_finished_loading = true
	_path_to_load = ""
	if not has_failed:
		emit_signal("loading_finished", _loaded_resource)


func _on_loading_thread_aborted() -> void:
	_path_to_load = ""
	_loaded_resource = null
	_is_aborting_load = false
	_has_finished_loading = false
	emit_signal("loading_safely_aborted")

### -----------------------------------------------------------------------------------------------
