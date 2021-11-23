# This is a helper node to be used together with a `eh_Resetable` resource.
# Just add this node as a child of a node that you want to trigger a reset when it exits the tree,
# and add the `eh_Resetable` resource you saved to disk in the exported variable of this node, using
# the editor. Then whenever this node exits the tree, together with it's parent, it will trigger
# the `reset_all` in the associated `eh_Resetable` resource.
class_name eh_ResetOnExit
extends Node

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

export(Array, Resource) var resetables: Array = []

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _exit_tree() -> void:
	for resource in resetables:
		var resetable: eh_Resetable = resource as eh_Resetable
		if resetable != null:
			resetable.reset_all()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
