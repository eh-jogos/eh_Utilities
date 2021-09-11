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

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
