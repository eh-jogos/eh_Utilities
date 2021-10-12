# Simple helper functions specially when writing code inside a `tool` script.
class_name eh_EditorHelpers
extends Reference

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

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
	return node.get_tree().current_scene == node


static func is_editor() -> bool:
	return Engine.editor_hint


static func has_editor() -> bool:
	return OS.has_feature("editor")


static func connect_between(
		from: Object, p_signal: String, 
		to: Object, p_callback: String, binds: = [], 
		type: = 0
) -> void:
	var is_alright: = OK
	if not from.is_connected(p_signal, to, p_callback):
		is_alright = from.connect(p_signal, to, p_callback, binds, type)
	if is_alright != OK:
		var msg = "failed to connect %s from %s to %s in %s"%[p_signal, from, p_callback, to]
		not_alright_error(from, msg, from.get_script())


static func disconnect_between(
		from: Object, p_signal: String, to: Object, p_callback: String
) -> void:
	if from.is_connected(p_signal, to, p_callback):
		from.disconnect(p_signal, to, p_callback)


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


static func add_debug_camera2D_to(node2D: Node2D, percent_offset: Vector2 = Vector2.INF) -> void:
	var camera: = Camera2D.new()
	camera.name = "DebugCamera2D"
	camera.current = true
	if percent_offset != Vector2.INF:
		var viewport_size = node2D.get_viewport_rect().size
		var total_offset = viewport_size * percent_offset
		var centered_offset = total_offset / 2.0
		camera.offset = centered_offset
	
	node2D.add_child(camera, true)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
