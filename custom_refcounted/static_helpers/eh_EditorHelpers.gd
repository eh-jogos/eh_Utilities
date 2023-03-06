class_name eh_EditorHelpers
extends RefCounted

## Static Helper for calling functions in the editor, usually on [code]@tool[/code] scripts

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const WARNING_VIRTUAL_FUNC = "%s is a virtual function and was called directly, without overriding"

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

static func disable_all_processing(node: Node) -> void:
	node.set_process_input(false)
	node.set_process_unhandled_input(false)
	node.set_process(false)
	node.set_physics_process(false)


static func is_standalone_run(node: Node) -> bool:
	return node.is_inside_tree() and node.get_tree().current_scene == node


static func has_editor() -> bool:
	return OS.has_feature("editor")


## Helper to connect signals with proper checking if it's not already connected.
static func connect_between(signal_object: Signal, callable: Callable, type := 0) -> void:
	if not signal_object.is_connected(callable):
		signal_object.connect(callable, type)


## Helper to disconnect signals with proper checking if a connection actually exists.
static func disconnect_between(signal_object: Signal, callable: Callable) -> void:
	if signal_object.is_connected(callable):
		signal_object.disconnect(callable)


static func erase_key_from_dictionary(object: Object, dict_name: String, key: String) -> void:
	var success = object.get(dict_name).erase(key)
	if not success:
		push_warning("Did not find key %s to delete in %s at %s"%[
				key, dict_name, object.get_script()
		])


static func get_reverse_range_for(p_array: Array) -> Array:
	return range(p_array.size()-1, -1, -1)


static func not_alright_error(who:Object, why: String, where: Script) -> void:
	var who_name: String = ""
	if who is Node:
		who_name = who.name
	elif who is Resource:
		who_name = who.resource_path
	elif who.get_script() != null:
		who_name = who.get_script().resource_path
	else:
		who_name = str(who)
	push_error("%s is not alright and %s at %s"%[who_name, why, where.resource_path])


static func add_debug_camera2D_to(
		node2D: Node2D, 
		percent_offset: Vector2 = Vector2(INF, INF), 
		zoom_level: Vector2 = Vector2.ONE
) -> void:
	var camera: = Camera2D.new()
	camera.name = "DebugCamera2D"
	camera.enabled = true
	camera.zoom = zoom_level
	if percent_offset != Vector2(INF, INF):
		var viewport_size = node2D.get_viewport_rect().size
		var total_offset = viewport_size * percent_offset
		var centered_offset = total_offset / 2.0
		camera.offset = centered_offset
	
	node2D.add_child(camera, true)


static func get_blend_position_paths_from(animation_tree: AnimationTree) -> Array:
	var blend_positions = []
	
	for property in animation_tree.get_property_list():
		if property.usage >= PROPERTY_USAGE_DEFAULT and property.name.ends_with("blend_position"):
			blend_positions.append(property.name)
	
	return blend_positions


static func get_class_name_string_for(script_path: String) -> String:
	var custom_classes := ProjectSettings.get_global_class_list()
	var name := ""
	for dictionary in custom_classes:
		if dictionary.path == script_path:
			name = dictionary["class"]
			break
	return name

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
