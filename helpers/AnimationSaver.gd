## I don't know if this script still works, I just adapted it to fix errors from appearing in the 
## editor. I think it would be better to convert this into a custom inspector that appears when
## an AnimationPlayer is selected in the inspector.
@tool
class_name AnimationSaver
extends Node

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export_dir var save_path: String = "": set = _set_save_path
@export var _animator_path: NodePath = NodePath("..") :
	set = _set_animator_path

#--- private variables - order: export > normal var > onready -------------------------------------

var _animator: AnimationPlayer = null :
	set = _set_animator

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if Engine.is_editor_hint():
		_set_animator(get_node(_animator_path))
		if save_path != "" and _animator != null:
			_save_all_animations()
			_reload_all_animations()


func _get_configuration_warnings() -> PackedStringArray:
	var msgs: = PackedStringArray()
	
	if save_path == "":
		msgs.append("You must choose a folder to save the animation resources")
	
	if _animator == null:
		msgs.append("You must set a valid path for an AnimationPlayer node in the inspector.")
	
	return msgs

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _save_all_animations() -> void:
	var final_directory: String = "%s/%s"%[save_path, _animator.name]
	var dir := DirAccess.open(save_path)
	if not dir.dir_exists(final_directory):
		dir.make_dir_recursive(final_directory)
	
	for animation_name in _animator.get_animation_list():
		var animation_resource = _animator.get_animation(animation_name)
		var file_path: String = "%s/%s.tres"%[final_directory, animation_name]
		# warning-ignore:return_value_discarded
		ResourceSaver.save(animation_resource, file_path)


func _reload_all_animations() -> void:
	var final_directory: String = "%s/%s"%[save_path, _animator.name]
	if not DirAccess.dir_exists_absolute(final_directory):
		push_error("couldn't find directory to load animations from: %s"%[final_directory])
		return
	
	for animation_name in _animator.get_animation_list():
		_animator.remove_animation_library(animation_name)
		var file_path: = "%s/%s.tres"%[final_directory, animation_name]
		var animation_resource = load(file_path)
		# warning-ignore:return_value_discarded
		_animator.add_animation_library(animation_name, animation_resource)


func _set_save_path(value: String) -> void:
	save_path = value
	update_configuration_warnings()


func _set_animator_path(value: NodePath) -> void:
	_animator_path = value
	
	if not is_inside_tree():
		await self.ready
	
	_set_animator(get_node_or_null(_animator_path))


func _set_animator(value: AnimationPlayer) -> void:
	_animator = value
	
	if not is_inside_tree():
		await self.ready
	
	update_configuration_warnings()

### -----------------------------------------------------------------------------------------------
