# This script is mostly to turn on or off the ability to create resources and nodes with
# teh custom types in this addon from the editor, otherwise the class_names inside "addons" folder 
# get ignored by the "Create New ..." or "Add Node" dialogs in the Editor.
#
# But their class_name's are still available in the code autocompletion, regardless if the plugin
# is activated or not, so things like the helpers in the static folder will work just as usual,
# but the custom nodes and custom resources will have their workflow hindered.
tool
class_name eh_UtilitiesEditorPlugin
extends EditorPlugin

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const SETTING_LOGGING_ENABLED = "eh_utilities/logging_enabled"

const SETTINGS = {
	SETTING_LOGGING_ENABLED: 
	{
		value = false, 
		type = TYPE_BOOL, 
		hint = PROPERTY_HINT_NONE, 
		hint_string = ""
	},
}

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _enter_tree() -> void:
	pass


func _exit_tree() -> void:
	pass


func enable_plugin() -> void:
	for setting in SETTINGS:
		if not ProjectSettings.has_setting(setting):
			var dict: Dictionary = SETTINGS[setting]
			ProjectSettings.set_setting(setting, dict.value)
			ProjectSettings.add_property_info({
				"name": setting,
				"type": dict.type,
				"hint": dict.hint,
				"hint_string": dict.hint_string,
			})
			ProjectSettings.save()


func disable_plugin() -> void:
	for setting in SETTINGS:
		if ProjectSettings.has_setting(setting):
			ProjectSettings.set_setting(setting, null)
			ProjectSettings.save()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
