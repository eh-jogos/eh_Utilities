# Helper class with logic to interpolate between 3d transforms correctly, but only interpolating
# rotation.
#
# Be careful when using as trying to interpolate in the same frame you `.new()` this class makes the
# tween bug. If you absolutely need to do this, you'll need to add a yield to "tween_all_completed" 
# after calling `interpolate_to` to force the interpolation to happen. That's why `setup` is 
# separate from `_init`, I usually declare one instance of eh_TransformTween as a member variable
# and cal `setup` during ready, or any other time the `_node` or `_tween` node need to change.
class_name eh_QuatTween
extends eh_TransformTween

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _quat_from: Quat
var _quat_to: Quat

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _init() -> void:
	pass

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------


func _setup_tween_variables(p_to: Transform) -> void:
	._setup_tween_variables(p_to)
	_quat_from = _from.basis.get_rotation_quat()
	_quat_to = _to.basis.get_rotation_quat()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _interpolate(progress: float) -> void:
	var new_quat = _quat_from.slerp(_quat_to, progress)
	var new_tranform = Transform(Basis(new_quat), _from.origin)
	_node.global_transform = new_tranform

### -----------------------------------------------------------------------------------------------
