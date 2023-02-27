@tool
extends ProgressBar

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@export_node_path("eh_SceneLoadAndTransition") var _path_transitioner_node: NodePath:
	set(value):
		_path_transitioner_node = value
		if Engine.is_editor_hint() and is_inside_tree():
			if is_instance_valid(_transitioner_node):
				_transitioner_node.wait_for_resume_changed.disconnect(update_configuration_warnings)
			_transitioner_node = get_node_or_null(_path_transitioner_node)
			if is_instance_valid(_transitioner_node):
				_transitioner_node.wait_for_resume_changed.connect(update_configuration_warnings)
			update_configuration_warnings()

var _tween: Tween = null

@onready var _transitioner_node := get_node(_path_transitioner_node) as eh_SceneLoadAndTransition

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if Engine.is_editor_hint():
		if is_instance_valid(_transitioner_node):
			_transitioner_node.wait_for_resume_changed.connect(update_configuration_warnings)
		return
	
	hide()
	_update_progress_bar(0.0)
	
	if is_instance_valid(_transitioner_node):
		_transitioner_node.loading_progressed.connect(_update_progress_bar)
		_transitioner_node.loading_wait_started.connect(_fade_in_progress_bar)
		_transitioner_node.loading_wait_finished.connect(_fade_out_progress_bar)


func _get_configuration_warnings() -> PackedStringArray:
	const WARN_NO_NODE = "No eh_SceneLoadAndTrasition node set in inspector."
	const WARN_NO_WAIT = (
			"eh_SceneLoadTransition wait_for_resume is false. Progress bar fade out will "
			+ "fail to display due to scene changing and this node being removed."
	)
	var warnings := PackedStringArray()
	
	if not is_instance_valid(_transitioner_node):
		warnings.append(WARN_NO_NODE)
	elif not _transitioner_node.wait_for_resume:
		warnings.append(WARN_NO_WAIT)
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _fade_in_progress_bar() -> void:
	modulate.a = 0.0
	show()
	
	if _tween != null:
		_tween.kill()
	
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.3)


func _fade_out_progress_bar() -> void:
	if _tween != null:
		_tween.kill()
	
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await _tween.finished
	_transitioner_node.resume_transition()


func _update_progress_bar(p_progress) -> void:
	value = p_progress

### -----------------------------------------------------------------------------------------------
