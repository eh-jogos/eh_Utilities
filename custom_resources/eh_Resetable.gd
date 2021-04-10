# A custom resource to help reset many things at once.
# 
# Let's say for example, that you have a puzzle game and the player can make changes to a "board"
# and reset it anytime to the initial state. You don't want to reload the scene as there are some
# information you want to keep, like the time the player has already spent at this level.
# This Resource can be a way to help you with that. 
#
# To use it, right click anywhere in the filesystem tab and create a "New Resource" of type
# `eh_Resetable`. In our example let's name it "board_reset.tres". Now on your Board Scene,
# load this "board_reset.tres" resource where you need and use `add_reset_function` publci method,
# passing the object itself, the name of the method in that object that you want to call when 
# "resetting" and if there are any arguments this method need, pass them all as an array.
#
# Then once the player presses the "Reset" button, just call the `reset_all` method in the loaded
# "board_reset.tres"! You won't need to worry about connecting signals, and you can easily add or
# remove methods to this reseter resource. You can have as many differente "reseter" resources as
# you need, if you need to reset different aspects of your game at different times.
tool
class_name eh_Resetable
extends Resource

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _reset_list: Dictionary = {}

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func has_object(p_object: Object) -> bool:
	var instance_id: int = p_object.get_instance_id()
	return _reset_list.has(instance_id)


func add_reset_function(p_object: Object, p_method: String, p_arguments: Array = []) -> void:
	var instance_id: int = p_object.get_instance_id()
	if not _reset_list.has(instance_id):
		# print("Adding reset for: %s"%[p_object.resource_name])
		_reset_list[instance_id] = {
			reset_function = funcref(p_object, p_method),
			arguments = p_arguments
		}


func remove_reset_for(p_object: Object) -> void:
	var instance_id: int = p_object.get_instance_id()
	if _reset_list.has(instance_id):
		_reset_list.erase(instance_id)


func reset_all() -> void:
	for dictionary in _reset_list.values():
		var reset_function: FuncRef = dictionary.reset_function
		reset_function.call_funcv(dictionary.arguments)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
