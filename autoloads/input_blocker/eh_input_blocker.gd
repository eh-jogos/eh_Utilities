# Useful scene for completely blocking input, can use it for things like Loading Screens,
# waiting for server connection or when enabling Steam Overlay, for example.
#
# It's really usefull is it is setup as an Autoload so that you can call it from anywhere
# and so that it's always above any screen.
extends CanvasLayer

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const INVALID_LAYER := -129

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _backup_layer: int = INVALID_LAYER

var _previous_focus: Control = null
@onready var _blocker = $Blocker as Control

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready():
	_blocker.hide()
	set_process_input(false)


func _input(event: InputEvent) -> void:
	get_viewport().set_input_as_handled()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func activate(p_previous_focus: Control = null, custom_layer: int = INVALID_LAYER) -> void:
	if custom_layer != INVALID_LAYER:
		_backup_layer = layer
		layer = custom_layer
	
	set_process_input(true)
	if p_previous_focus == null:
		_previous_focus = _blocker.get_viewport().gui_get_focus_owner()
	else:
		_previous_focus = p_previous_focus
	
	_blocker.show()
	_blocker.grab_focus()


func deactivate() -> void:
	_blocker.hide()
	set_process_input(false)
	
	if _backup_layer != INVALID_LAYER and _backup_layer != layer:
		layer = _backup_layer
	
	if _previous_focus != null and is_instance_valid(_previous_focus):
		_previous_focus.grab_focus()
		_previous_focus = null

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
