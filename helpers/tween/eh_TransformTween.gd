# Helper class with logic to interpolate 3d transforms correctly, taking into account both
# translation and rotation.
#
# Be careful when using as trying to interpolate in the same frame you `.new()` this class makes the
# tween bug. If you absolutely need to do this, you'll need to add a yield to "tween_all_completed" 
# after calling `interpolate_to` to force the interpolation to happen. That's why `setup` is 
# separate from `_init`, I usually declare one instance of eh_TransformTween as a member variable
# and cal `setup` during ready, or any other time the `_node` or `_tween` node need to change.
class_name eh_TransformTween
extends Reference

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _node: Spatial
var _from: Transform
var _to: Transform
var _quat_from: Quat
var _quat_to: Quat

var _tween: Tween

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _init() -> void:
	pass

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func setup(p_node: Spatial, p_tween: Tween) -> void:
	_node = p_node
	_tween = p_tween


func interpolate_to(
		p_to: Transform, 
		duration: float, 
		trans_type: = Tween.TRANS_LINEAR, 
		ease_type: = Tween.EASE_IN_OUT
) -> bool:
	var success: = false
	_from = _node.global_transform
	_to = p_to
	
	_quat_from = _from.basis.get_rotation_quat()
	_quat_to = _to.basis.get_rotation_quat()
	
	success = _tween.interpolate_method(
			self, "_interpolate", 0.0, 1.0, duration, trans_type, ease_type)
	if not success:
		_push_generic_tween_error("Failed to add interpolate method for %s in %s")
		return success
	
	success = _tween.start()
	if not success:
		push_error("Failed to start interpolation of %s to %s"%[_node.name, _to])
		assert(false)
	
	return success


func stop_interpolation() -> bool:
	var success = false
	success = _tween.stop(_node, "_interpolate")
	if not success:
		_push_generic_tween_error("Failed to stop interpolation for %s in %s")
	return success


func resume_interpolation() -> bool:
	var success: = false
	success = _tween.resume(_node, "_interpolate")
	if not success:
		_push_generic_tween_error("Failed to resume interpolation for %s in %s")
	return success


func reset_interpolation() -> bool:
	var success: = false
	success = _tween.reset(_node, "_interpolate")
	if not success:
		_push_generic_tween_error("Failed to reset interpolation for %s in %s")
	return success


func remove_interpolation() -> bool:
	var success: = false
	success = _tween.remove(_node, "_interpolate")
	if not success:
		_push_generic_tween_error("Failed to remove interpolation for %s in %s")
	return success

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _push_generic_tween_error(msg: String) -> void:
	push_error(msg%[_node.name, _tween.name])
	assert(false)


func _interpolate(progress: float) -> void:
	var new_origin = lerp(_from.origin, _to.origin, progress)
	var new_quat = _quat_from.slerp(_quat_to, progress)
	var new_tranform = Transform(Basis(new_quat), new_origin)
	_node.global_transform = new_tranform

### -----------------------------------------------------------------------------------------------
