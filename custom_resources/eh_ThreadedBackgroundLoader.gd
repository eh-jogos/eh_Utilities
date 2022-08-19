# Write your doc string for this file here
class_name eh_ThreadedBackgroundLoader
extends Resource

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

signal loading_progressed(progress_value)
signal loading_finished(loaded_resource)
signal loading_thread_aborted
signal loading_safely_aborted

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _path_to_load := "" setget set_path_to_load, get_path_to_load
var _loader: ResourceInteractiveLoader = null
var _loading_thread: Thread = null

var _loaded_resource: Resource = null

var _is_aborting_load := false
var _mutex := Mutex.new()

var _has_finished_loading := false

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _init() -> void:
	eh_EditorHelpers.connect_between(
			self, "loading_finished", 
			self, "_on_loading_finished", 
			[], CONNECT_DEFERRED
	)

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func set_path_to_load(value: String) -> void:
	if _loading_thread != null:
		var msg = "Can't set path to load while another path is being loaded. "\
				+ "Abort current loading first"
		push_error(msg)
		return
	
	if ResourceLoader.exists(value):
		if not _path_to_load.empty():
			var msg = (
					"Path given is different from previously set but not loaded path."
					+"%s will overwrite the current path %s"%[
						value, _path_to_load
					]
			)
			push_warning(msg)
		
		_path_to_load = value
		_loader = ResourceLoader.load_interactive(_path_to_load)
	else:
		push_warning("%s is an invalid resource path.")


func get_path_to_load() -> String:
	return _path_to_load


func get_total_stages() -> int:
	var value := 0
	
	if _loader != null:
		value = _loader.get_stage_count()
	
	return value


func has_finished() -> bool:
	return _has_finished_loading


func start_loading(p_path: String = "") -> void:
	if _is_aborting_load:
		yield(self, "loading_safely_aborted")
	
	if _loading_thread != null:
		push_error("This Loader is already busy loading: %s"%[_path_to_load])
		return
	
	if not p_path.empty():
		set_path_to_load(p_path)
	
	if _path_to_load.empty():
		if p_path.empty():
			push_error(
					"You need to provide a valid resource path to load." 
					+"Either by sending it as an argument to start_loading or by setting "
					+"it before hand with set_path_to_load."
			)
		return
	
	clear_loaded_resource()
	_loading_thread = Thread.new()
	_loading_thread.start(self, "_load_on_thread", p_path)


func get_loaded_resource() -> Resource:
	return _loaded_resource


func clear_loaded_resource() -> void:
	if _loading_thread != null:
		push_error("Can't clear loaded resource while still loading. Use abort_loading instead.")
		return
	
	_loaded_resource = null
	_has_finished_loading = false


func abort_loading() -> void:
	eh_EditorHelpers.connect_between(
		self, "loading_aborted", self, "loading_thread_aborted", [], CONNECT_DEFERRED
	)
	_mutex.lock()
	_is_aborting_load = true
	_mutex.unlock()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _load_on_thread(p_path) -> void:
	var tree: = Engine.get_main_loop() as SceneTree
	var total_stages := float(_loader.get_stage_count())
	
	var status = _loader.poll()
	while status == OK:
		var progress := _loader.get_stage()/total_stages
		emit_signal("loading_progressed", progress)
		
		yield(tree, "idle_frame")
		
		_mutex.lock()
		var should_abort: = _is_aborting_load
		_mutex.unlock()
		
		if should_abort:
			status = ERR_PRINTER_ON_FIRE
			break
		else:
			status = _loader.poll()
	
	if status == ERR_FILE_EOF:
		_loaded_resource = _loader.get_resource()
		emit_signal("loading_progressed", 1.0)
		emit_signal("loading_finished", _loaded_resource)
	elif status == ERR_PRINTER_ON_FIRE:
		emit_signal("loading_thread_aborted")
	else:
		push_error("Something went wrong when trying to load %s. Error Code: %s"%[
				p_path, status
		])
		_on_loading_finished(null)


func _on_loading_finished(_resource: Resource) -> void:
	_path_to_load = ""
	_loading_thread.wait_to_finish()
	_loading_thread = null
	_loader = null
	_has_finished_loading = true


func _on_loading_thread_aborted() -> void:
	_path_to_load = ""
	_loading_thread.wait_to_finish()
	_loading_thread = null
	_loaded_resource = null
	_loader = null
	_is_aborting_load = false
	_has_finished_loading = false

### -----------------------------------------------------------------------------------------------
