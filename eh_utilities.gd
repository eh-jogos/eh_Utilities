class_name eh_Utilities
extends RefCounted

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const PATH_CUSTOM_INSPECTORS = "res://addons/eh_jogos.utilities/custom_inspectors/"
const PATH_AUTOLOADS_FOLDER = "res://addons/eh_jogos.utilities/autoloads/"

const SETTING_AUTOLOADS_BASE = "eh_jogos/eh_utilities/autoloads/"
const SETTING_LOGGING_ENABLED = "eh_jogos/eh_utilities/autoloads/eh_DebugLogger_enabled"
const SETTING_INPUT_BLOCKING_ENABLED = "eh_jogos/eh_utilities/autoloads/eh_InputBlocker_enabled"
const SETTINGS = {
	SETTING_LOGGING_ENABLED: 
	{
		value = true, 
		type = TYPE_BOOL, 
		hint = PROPERTY_HINT_NONE, 
		hint_string = ""
	},
	SETTING_INPUT_BLOCKING_ENABLED: 
	{
		value = true, 
		type = TYPE_BOOL, 
		hint = PROPERTY_HINT_NONE, 
		hint_string = ""
	},
}

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

static func get_default_setting(setting_name: String) -> Variant:
	return SETTINGS[setting_name].value

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
