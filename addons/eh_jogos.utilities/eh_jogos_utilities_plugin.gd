# This script is mostly to turn on or off the ability to create resources and nodes with
# teh custom types in this addon from the editor, otherwise the class_names inside "addons" folder 
# get ignored by the "Create New ..." or "Add Node" dialogs in the Editor.
#
# But their class_name's are still available in the code autocompletion, regardless if the plugin
# is activated or not, so things like the helpers in the static folder will work just as usual,
# but the custom nodes and custom resources will have their workflow hindered.
tool
extends EditorPlugin

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const PATH_CUSTOM_INSPECTORS = "res://addons/eh_jogos.utilities/custom_inspectors/"

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

var _loaded_inspectors := {}

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _enter_tree() -> void:
	_add_custom_inspectors()


func _exit_tree() -> void:
	_remove_custom_inspectors()


func enable_plugin() -> void:
	_add_plugin_settings()


func disable_plugin() -> void:
	_remove_plugin_settings()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _add_plugin_settings() -> void:
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


func _remove_plugin_settings() -> void:
	for setting in SETTINGS:
		if ProjectSettings.has_setting(setting):
			ProjectSettings.set_setting(setting, null)
			ProjectSettings.save()


func _add_custom_inspectors() -> void:
	var dir := Directory.new()
	var error := dir.open(PATH_CUSTOM_INSPECTORS)
	
	if error == OK:
		dir.list_dir_begin()
		var folder_name := dir.get_next()
		while not folder_name.empty():
			if dir.current_is_dir(): 
				_load_custom_inspector_from(folder_name)
			folder_name = dir.get_next()
	else:
		var error_msg = "Error code: %s | Something went wrong trying to open %s"%[
			error, PATH_CUSTOM_INSPECTORS
		]
		push_error(error_msg)


func _load_custom_inspector_from(folder: String) -> void:
	var PATH_SCRIPT = "inspector_plugin.gd"
	var full_path := PATH_CUSTOM_INSPECTORS.plus_file(folder).plus_file(PATH_SCRIPT)
	if ResourceLoader.exists(full_path):
		var custom_inspector := load(full_path).new() as EditorInspectorPlugin
		add_inspector_plugin(custom_inspector)
		
		if "undo_redo" in custom_inspector:
			custom_inspector.undo_redo = get_undo_redo()
		
		if "parent_plugin" in custom_inspector:
			custom_inspector.parent_plugin = self
		
		_loaded_inspectors[folder] = custom_inspector


func _remove_custom_inspectors() -> void:
	for inspector in _loaded_inspectors.values():
		remove_inspector_plugin(inspector)

### -----------------------------------------------------------------------------------------------
