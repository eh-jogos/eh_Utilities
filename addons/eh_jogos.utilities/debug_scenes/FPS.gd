# Write your doc string for this file here
extends Label

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _process(delta: float) -> void:
	text = "FPS: %s"%[Performance.get_monitor(Performance.TIME_FPS)]

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------


### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
