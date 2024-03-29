# Based mainly on [Squirrel Eiserloh's GDC Talk]
# (https://www.youtube.com/watch?v=tu-Qe66AvtY&list=PLBfFh5W1T7RItlrRJryozPUE6tpO0uOHT&index=46&t=4s)
# , [Kid's Can Code Godot Recipe] (https://kidscancode.org/godot_recipes/2d/screen_shake/) for an
# initial Godot Script and adpatations, plus [this tutorial]
# (http://www.briscoe.ca/notes/camera-shake/) to add direction.
# It works for any Node2D, not only Camera3D, and it's already responsive to changes in 
# time scale (like slow motion or any other effect of this kind).
#
# But try to add it to nodes which the position and rotation does not change during runtime, or 
# at least do not change often. The code tries to acknowledge the base position and base rotation 
# of the target node, but it only updates when you add trauma and trauma was 0, so it won't update 
# again until the shake stops. 
# If you need to add to a camera or player, add a "pivot" Node2D that holds the position and 
# rotation for the object so that you can move the pivot around. Or add a "ShakyCamera" as a child 
# of you normal camera and this Shaker to it. In the case of the player, you can add the Shaker 
# only to the player's skin and not to the Kinematic/RigidBody3D.
@tool
class_name eh_Shaker2D
extends Node

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

signal trauma_ended

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const TIME_UNIT = 0.0001

#--- public variables - order: export > normal var > onready --------------------------------------

@export var shake_target: NodePath = NodePath("..")

# How quickly the shaking stops [0, 1].
@export var decay: float = 0.8  
# Maximum hor/ver shake in pixels.
@export var max_offset: Vector2 = Vector2(100, 75)  
# Maximum rotation in degrees.
@export_range(0.0, 360.0, 0.1) var max_roll: float = 0.1
# Trauma exponent.
@export_range(2,3,1) var trauma_power: int = 2

#--- private variables - order: export > normal var > onready -------------------------------------

# To visualize the noise properties we are using
@export var _noise_texture: NoiseTexture2D = null
# For smooth randomness in the shake movement.
var _noise: FastNoiseLite = null

# Current shake strength. Should be a value between 0 and 1.
var _trauma: float = 0.0
# Predominant direction of shake. 
var _direction: Vector2 = Vector2.ZERO

var _time: float = 0.0

var base_offset: Vector2 = Vector2.ZERO
var base_rotation: float = 0

# Test and Debugging Variables for the editor
var _test_trauma: float = 0.0 :
	set = _set_test_trauma
var _test_direction: Vector2 = Vector2.ZERO :
	set = _set_test_direction

@onready var _target: CanvasItem = get_node(shake_target)

## These are just some arbitrary values to take samples for each axis at a fair amount of
## distance from each other. I used to just use the seed like in the kid's can code linked, but
## it doesn't work on godot 4, some huge integers (above 10.000.000) give errors, even though they 
## are valid as seeds
var _sampling_distance := randi_range(512, 1024)

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready():
	randomize()
	_handle_noise()
	_update_base_values()


func _process(delta):
	if _trauma:
		_trauma = max(_trauma - decay * delta * Engine.time_scale, 0)
		_shake()
	else:
		_update_base_values()
		set_process(false)
		emit_signal("trauma_ended")


func _get_property_list() -> Array:
	var list: = []
	
	list.append({
		"name": "Test Variables",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_CATEGORY,
	})
	list.append({
		"name": "_test_trauma",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_SCRIPT_VARIABLE | PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0,1,0.01"
	})
	list.append({
		"name": "_test_direction",
		"type": TYPE_VECTOR2,
		"usage": PROPERTY_USAGE_SCRIPT_VARIABLE | PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "-1,1,0.01"
	})
	
	return list

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func add_trauma(amount: float, direction: = Vector2.ZERO):
	if _trauma == 0:
		_update_base_values()
	
	_trauma = min(_trauma + amount, 1.0)
	
	_direction = direction
	if direction.length() > 1:
		_direction = direction.normalized()
	
	if not is_processing() and _trauma > 0:
		set_process(true)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _set_test_trauma(value: float) -> void:
	_test_trauma = clamp(value, 0, 1)
	
	if not is_inside_tree():
		return
	
	_test_add_trauma()


func _set_test_direction(value: Vector2) -> void:
	_test_direction = value
	if _test_direction.length() > 1:
		_test_direction = _test_direction.normalized()
	
	if not is_inside_tree():
		return
	
	_test_add_trauma()


func _test_add_trauma() -> void:
	if Engine.is_editor_hint():
		add_trauma(_test_trauma, _test_direction)
	else:
		push_warning("This variable is only for tests in the editor, it doesn't work in runtime.")


func _handle_noise() -> void:
	if _noise_texture == null:
		_noise = FastNoiseLite.new()
		_noise.seed = randi()
		_noise.period = 4
		_noise.octaves = 2
		_noise_texture = NoiseTexture2D.new()
		_noise_texture.noise = _noise
	else:
		_noise = _noise_texture.noise


func _update_base_values() -> void:
	if _target is Node2D:
		if _target.position != base_offset:
			base_offset = _target.position
		
		if _target.rotation != base_rotation:
			base_rotation = _target.rotation
	elif _target is Control:
		if _target.position != base_offset:
			base_offset = _target.position
		
		if _target.rotation != base_rotation:
			base_rotation = _target.rotation


func _shake():
	var shake_amount = pow(_trauma, trauma_power)
	_time += 1 * Engine.time_scale
	
	var rotation_factor = (
			deg_to_rad(max_roll) * shake_amount 
			* _noise.get_noise_2d(_sampling_distance, _time)
	)
	var translation_x_factor = (
			max_offset.x * shake_amount 
			* (_direction.x + _noise.get_noise_2d(_sampling_distance * 2, _time))
	)
	var translation_y_factor = (
			max_offset.y * shake_amount 
			* (_direction.y + _noise.get_noise_2d(_sampling_distance * 3, _time))
	)
	
	_target.rotation = base_rotation + rotation_factor
	_target.position.x = base_offset.x + translation_x_factor
	_target.position.y = base_offset.y + translation_y_factor

### -----------------------------------------------------------------------------------------------
