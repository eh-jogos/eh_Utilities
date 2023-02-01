# Helper class with logic to sample 3d transforms correctly, taking into account both
# position and rotation.
#
# TODO: TEST IF THIS IS A PROBLEM ON GODOT 4 as Tween is not a node anymore
# Be careful when using as trying to sample in the same frame you `.new()` this class makes the
# tween bug. If you absolutely need to do this, you'll need to add a yield to "tween_all_completed" 
# after calling `interpolate_to` to force the interpolation to happen. That's why `setup` is 
# separate from `_init`, I usually declare one instance of eh_TransformTween as a member variable
# and cal `setup` during ready, or any other time the `_node` or `_tween` node need to change.
@tool
class_name eh_TransformTween
extends RefCounted

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

var is_verbose: bool = false

#--- private variables - order: export > normal var > onready -------------------------------------

var _node: Node3D
var _from: Transform3D
var _to: Transform3D

var _tween: Tween

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _init():
	pass

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func setup(p_node: Node3D) -> void:
	_node = p_node


func interpolate_to(
		p_to: Transform3D, 
		duration: float, 
		trans_type: = Tween.TRANS_LINEAR, 
		ease_type: = Tween.EASE_IN_OUT
) -> void:
	var success: = false
	_setup_tween_variables(p_to)
	
	if _tween:
		_tween.kill()
	
	_tween = _node.create_tween().set_trans(trans_type).set_ease(ease_type)
	_tween.tween_method(_interpolate, 0.0, 1.0, duration)


func pause_interpolation() -> void:
	if _tween:
		_tween.pause()


func resume_interpolation() -> void:
	if _tween:
		_tween.play()


func reset_interpolation() -> void:
	if _tween:
		_tween.stop()


func remove_interpolation() -> void:
	if _tween:
		_tween.kill()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _setup_tween_variables(p_to: Transform3D) -> void:
	_from = _node.global_transform
	_to = p_to


func _interpolate(progress: float) -> void:
	var new_transform = _from.interpolate_with(_to, progress)
	if is_verbose:
		print("progress: %s | new_transform: %s"%[progress, new_transform])
	
	_node.global_transform = new_transform

### -----------------------------------------------------------------------------------------------
