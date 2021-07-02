# Write your doc string for this file here
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

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
