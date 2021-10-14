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

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _previous_focus: Control = null
onready var _blocker = $Blocker

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready():
	_blocker.hide()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func activate() -> void:
	_previous_focus = _blocker.get_focus_owner()
	_blocker.show()
	_blocker.grab_focus()


func deactivate() -> void:
	_blocker.hide()
	if _previous_focus != null and is_instance_valid(_previous_focus):
		_previous_focus.grab_focus()
		_previous_focus = null

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
