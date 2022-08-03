# Write your doc string for this file here
tool
class_name AnimationSaver
extends Node

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

export(String, DIR) var save_path: String = "" setget _set_save_path
export var _animator_path: NodePath = NodePath("..") setget _set_animator_path

#--- private variables - order: export > normal var > onready -------------------------------------

var _animator: AnimationPlayer = null setget _set_animator

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if eh_EditorHelpers.is_editor():
		_set_animator(get_node(_animator_path))
		if save_path != "" and _animator != null:
			_save_all_animations()
			_reload_all_animations()


func _get_configuration_warning() -> String:
	var msg: = ""
	
	if save_path == "":
		msg += "You must choose a folder to save the animation resources"
	
	if _animator == null:
		msg += "\nYou must set a valid path for an AnimationPlayer node in the inspector."
	
	return msg

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _save_all_animations() -> void:
	var final_directory: String = "%s/%s"%[save_path, _animator.name]
	var dir = Directory.new()
	if not dir.dir_exists(final_directory):
		dir.make_dir_recursive(final_directory)
	
	for animation_name in _animator.get_animation_list():
		var animation_resource = _animator.get_animation(animation_name)
		var file_path: String = "%s/%s.tres"%[final_directory, animation_name]
		# warning-ignore:return_value_discarded
		ResourceSaver.save(file_path, animation_resource)


func _reload_all_animations() -> void:
	var final_directory: String = "%s/%s"%[save_path, _animator.name]
	var dir = Directory.new()
	if not dir.dir_exists(final_directory):
		push_error("couldn't find directory to load animations from: %s"%[final_directory])
		return
	
	for animation_name in _animator.get_animation_list():
		_animator.remove_animation(animation_name)
		var file_path: = "%s/%s.tres"%[final_directory, animation_name]
		var animation_resource = load(file_path)
		# warning-ignore:return_value_discarded
		_animator.add_animation(animation_name, animation_resource)


func _set_save_path(value: String) -> void:
	save_path = value
	update_configuration_warning()


func _set_animator_path(value: NodePath) -> void:
	_animator_path = value
	
	if not is_inside_tree():
		yield(self, "ready")
	
	_set_animator(get_node_or_null(_animator_path))


func _set_animator(value: AnimationPlayer) -> void:
	_animator = value
	
	if not is_inside_tree():
		yield(self, "ready")
	
	update_configuration_warning()

### -----------------------------------------------------------------------------------------------
