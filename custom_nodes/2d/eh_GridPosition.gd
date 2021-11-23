# A Position2D that also shows the position as a grid or tilemap value.
tool
class_name eh_GridPosition
extends Position2D

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

var tile_position: Vector2 = Vector2.ZERO setget _set_tile_position
var global_tile_position: Vector2 = Vector2.ZERO \
		setget _set_global_tile_position, _get_global_tile_position

#--- private variables - order: export > normal var > onready -------------------------------------

var _use_tilemap: bool = false setget _set_use_tilemap
var _path_tilemap: NodePath = NodePath("") setget _set_path_tilemap
var _reference_position: Vector2 = Vector2.ZERO
var _reference_tile_size: Vector2 = Vector2(16, 16) setget _set_reference_tile_size

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _init() -> void:
	set_process(false)


func _ready() -> void:
	_update_reference_position()
	if Engine.editor_hint:
		set_process(true)


func _process(_delta: float) -> void:
	if _reference_tile_size.x != 0 and _reference_tile_size.y != 0:
		var new_tile_position: = (global_position - _reference_position) / _reference_tile_size
		_set_tile_position(new_tile_position)

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _update_reference_position() -> void:
	_reference_position = get_parent().global_position if get_parent() is Node2D else Vector2.ZERO


func _set_tile_position(value: Vector2) -> void:
	if tile_position != value:
		tile_position = value
		
		if not is_inside_tree():
			yield(self, "ready")
		
		position = tile_position * _reference_tile_size
		property_list_changed_notify()


func _set_global_tile_position(value: Vector2) -> void:
	if global_tile_position != value:
		global_tile_position = value
		
		if not is_inside_tree():
			yield(self, "ready")
		
		global_position = global_tile_position * _reference_tile_size
		property_list_changed_notify()


func _get_global_tile_position() -> Vector2:
	return global_position / _reference_tile_size


func _set_use_tilemap(value: bool) -> void:
	_use_tilemap = value
	
	if not is_inside_tree():
			yield(self, "ready")
	
	if _use_tilemap and _path_tilemap == NodePath(""):
		_update_reference_position()
		_reference_tile_size = Vector2.ZERO
	
	property_list_changed_notify()
	update_configuration_warning()


func _set_path_tilemap(value: NodePath) -> void:
	_path_tilemap = value
	
	if not is_inside_tree():
		yield(owner, "ready")
	
	var tilemap: TileMap = get_node_or_null(_path_tilemap)
	print("path: %s | node: %s"%[_path_tilemap, tilemap])
	if tilemap != null:
		_reference_position = tilemap.global_position
		_reference_tile_size = tilemap.cell_size
	else:
		_path_tilemap = NodePath("")
		_update_reference_position()
		_reference_tile_size = Vector2.ZERO
	
	property_list_changed_notify()
	update_configuration_warning()


func _set_reference_tile_size(value: Vector2) -> void:
	_reference_tile_size = value
	property_list_changed_notify()
	update_configuration_warning()

### -----------------------------------------------------------------------------------------------

##################################################################################################
# Custom Inspector ################################################################################
##################################################################################################

### Editor Methods --------------------------------------------------------------------------------

func _get_property_list() -> Array:
	var properties: = []
	
	var dict: = {}
	if _reference_tile_size.x != 0 and _reference_tile_size.y != 0:
		dict = eh_InspectorHelper.get_property_dict_for("tile_position", TYPE_VECTOR2)
		properties.append(dict)
		dict = eh_InspectorHelper.get_property_dict_for("global_tile_position", TYPE_VECTOR2)
		properties.append(dict)
	
	dict = eh_InspectorHelper.get_category_dict("Configuration")
	properties.append(dict)
	dict = eh_InspectorHelper.get_property_dict_for("_use_tilemap", TYPE_BOOL)
	properties.append(dict)
	
	if _use_tilemap:
		dict = eh_InspectorHelper.get_property_dict_for("_path_tilemap", TYPE_NODE_PATH)
		properties.append(dict)
	else:
		dict = eh_InspectorHelper.get_property_dict_for("_reference_position", TYPE_VECTOR2)
		properties.append(dict)
		dict = eh_InspectorHelper.get_property_dict_for("_reference_tile_size", TYPE_VECTOR2)
		properties.append(dict)
	
	return properties


func _get(property: String):
	var to_return = null

	return to_return


func _set(property: String, value) -> bool:
	var has_handled: = false

	return has_handled


func _get_configuration_warning() -> String:
	var msg: = ""
	
	if _use_tilemap and _path_tilemap == NodePath(""):
		msg = "You must set '_path_tilemap' property to a TileMap node in the inspector."
	elif _reference_tile_size.x == 0 or _reference_tile_size.y == 0:
		msg = "All component of _reference_tile_size must be greater than 0."
	
	return msg

### -----------------------------------------------------------------------------------------------
