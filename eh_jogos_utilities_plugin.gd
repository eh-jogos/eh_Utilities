# This script is mostly to turn on or off the ability to create resources and nodes with
# the custom types in this addon from the editor, otherwise the class_names inside "addons" folder 
# get ignored by the "Create New ..." or "Add Node" dialogs in the Editor.
#
# But their class_name's are still available in the code autocompletion, regardless if the plugin
# is activated or not, so things like the helpers in the static folder will work just as usual,
# but the custom nodes and custom resources will have their workflow hindered.
@tool
class_name eh_Utilities
extends EditorPlugin

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const PATH_CUSTOM_INSPECTORS = "res://addons/eh_jogos.utilities/custom_inspectors/"

const SETTING_LOGGING_ENABLED = "eh_jogos/eh_utilities/logging_enabled"
const SETTINGS = {
	SETTING_LOGGING_ENABLED: 
	{
		value = true, 
		type = TYPE_BOOL, 
		hint = PROPERTY_HINT_NONE, 
		hint_string = ""
	},
}

const PATH_AUTOLOADS = [
	["eh_DebugLogger", "res://addons/eh_jogos.utilities/autoloads/debug_logger/eh_debug_logger.tscn"],
]


#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

var _loaded_inspectors := {}

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _enter_tree() -> void:
	_add_custom_inspectors()
	_add_settings_property_info()


func _exit_tree() -> void:
	_remove_custom_inspectors()


func _enable_plugin() -> void:
	_add_plugin_settings()
	_add_settings_property_info()
	_add_autoloads()


func _disable_plugin() -> void:
	_remove_plugin_settings()
	_remove_autoloads()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _add_plugin_settings() -> void:
	for setting in SETTINGS:
		var dict: Dictionary = SETTINGS[setting]
		if not ProjectSettings.has_setting(setting):
			ProjectSettings.set_setting(setting, dict.value)
	
	get_editor_interface().get_resource_filesystem().scan()
	
	if Engine.is_editor_hint():
		ProjectSettings.save()


func _add_settings_property_info() -> void:
	for setting in SETTINGS:
		var dict: Dictionary = SETTINGS[setting]
		ProjectSettings.add_property_info({
			"name": setting,
			"type": dict.type,
			"hint": dict.hint,
			"hint_string": dict.hint_string,
		})
	
	get_editor_interface().get_resource_filesystem().scan()
	
	if Engine.is_editor_hint():
		ProjectSettings.save()


func _remove_plugin_settings() -> void:
	for setting in SETTINGS:
		if ProjectSettings.has_setting(setting):
			ProjectSettings.set_setting(setting, null)
			ProjectSettings.save()


func _add_custom_inspectors() -> void:
	if not DirAccess.dir_exists_absolute(PATH_CUSTOM_INSPECTORS):
		var error_msg = "Path Doesn't exists: %s"%[PATH_CUSTOM_INSPECTORS]
		push_error(error_msg)
	
	var dir := DirAccess.open(PATH_CUSTOM_INSPECTORS)
	for folder_name in dir.get_directories():
		_load_custom_inspector_from(folder_name)


func _load_custom_inspector_from(folder: String) -> void:
	const PATH_SCRIPT = "inspector_plugin.gd"
	var full_path := PATH_CUSTOM_INSPECTORS.path_join(folder).path_join(PATH_SCRIPT)
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


func _add_autoloads() -> void:
	for autoload_data in PATH_AUTOLOADS:
		var autoload_name = autoload_data[0]
		if not ProjectSettings.has_setting("autoload/%s"%[autoload_name]):
			var path = autoload_data[1]
			add_autoload_singleton(autoload_name, path)


func _remove_autoloads() -> void:
	for autoload_data in PATH_AUTOLOADS:
		var autoload_name = autoload_data[0]
		if ProjectSettings.has_setting("autoload/%s"%[autoload_name]):
			var original_path := autoload_data[1] as String
			var current_path := ProjectSettings.get_setting("autoload/%s"%[autoload_name]) as String
			if "*%s"%[original_path] == current_path:
				remove_autoload_singleton(autoload_name)

### -----------------------------------------------------------------------------------------------
