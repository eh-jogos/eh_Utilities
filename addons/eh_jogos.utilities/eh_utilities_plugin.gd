# This script is mostly to turn on or off the ability to create resources and nodes with
# the custom types in this addon from the editor, otherwise the class_names inside "addons" folder 
# get ignored by the "Create New ..." or "Add Node" dialogs in the Editor.
#
# But their class_name's are still available in the code autocompletion, regardless if the plugin
# is activated or not, so things like the helpers in the static folder will work just as usual,
# but the custom nodes and custom resources will have their workflow hindered.
@tool
extends EditorPlugin

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const PATH_AUTOLOADS = [
	["eh_DebugLogger", "debug_logger/eh_debug_logger.tscn"],
	["eh_InputBlocker", "input_blocker/eh_input_blocker.tscn"]
]


#--- public variables - order: export > normal var > onready --------------------------------------

var editor_interface: EditorInterface
var editor_file_system: EditorFileSystem

#--- private variables - order: export > normal var > onready -------------------------------------

var _loaded_inspectors := {}

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _enter_tree() -> void:
	editor_interface = get_editor_interface()
	editor_file_system = editor_interface.get_resource_filesystem()
	_add_custom_inspectors()
	_add_plugin_settings()
	_add_settings_property_info()
	add_tool_menu_item("Copy Script Templates from Utilities", _copy_script_templates_to_project)


func _ready() -> void:
	eh_EditorHelpers.connect_between(project_settings_changed, _on_project_settings_changed)


func _exit_tree() -> void:
	_remove_custom_inspectors()
	remove_tool_menu_item("Copy Script Templates from Utilities")


func _enable_plugin() -> void:
	eh_EditorHelpers.connect_between(project_settings_changed, _on_project_settings_changed)
	_add_autoloads()


func _disable_plugin() -> void:
	eh_EditorHelpers.disconnect_between(project_settings_changed, _on_project_settings_changed)
	_remove_autoloads()
	_remove_plugin_settings()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

####### Custom Inspectors -------------------------------------------------------------------------

func _add_custom_inspectors() -> void:
	if not DirAccess.dir_exists_absolute(eh_Utilities.PATH_CUSTOM_INSPECTORS):
		var error_msg = "Path Doesn't exists: %s"%[eh_Utilities.PATH_CUSTOM_INSPECTORS]
		push_error(error_msg)
	
	var dir := DirAccess.open(eh_Utilities.PATH_CUSTOM_INSPECTORS)
	for folder_name in dir.get_directories():
		_load_custom_inspector_from(folder_name)


func _load_custom_inspector_from(folder: String) -> void:
	const PATH_SCRIPT = "inspector_plugin.gd"
	var full_path := eh_Utilities.PATH_CUSTOM_INSPECTORS.path_join(folder).path_join(PATH_SCRIPT)
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

####### End of Custom Inspectors ------------------------------------------------------------------

####### Project Settings --------------------------------------------------------------------------

func _add_plugin_settings() -> void:
	for setting in eh_Utilities.SETTINGS:
		var dict: Dictionary = eh_Utilities.SETTINGS[setting]
		if not ProjectSettings.has_setting(setting):
			ProjectSettings.set_setting(setting, dict.value)
			ProjectSettings.set_initial_value(setting, dict.value)
	
	for data in PATH_AUTOLOADS:
		var autoload_name = eh_Utilities.SETTING_AUTOLOADS_BASE.path_join(data[0])
		var autoload_path = eh_Utilities.PATH_AUTOLOADS_FOLDER.path_join(data[1])
		
		if not ProjectSettings.has_setting(autoload_name):
			ProjectSettings.set_setting(autoload_name, autoload_path)
			ProjectSettings.set_initial_value(autoload_name, autoload_path)
		
	
	if Engine.is_editor_hint():
		ProjectSettings.save()
		editor_file_system.scan()


func _add_settings_property_info() -> void:
	for setting in eh_Utilities.SETTINGS:
		var dict: Dictionary = eh_Utilities.SETTINGS[setting]
		ProjectSettings.add_property_info({
			"name": setting,
			"type": dict.type,
			"hint": dict.hint,
			"hint_string": dict.hint_string,
		})
	
	for data in PATH_AUTOLOADS:
		var autoload_name = eh_Utilities.SETTING_AUTOLOADS_BASE.path_join(data[0])
		ProjectSettings.add_property_info({
			"name": autoload_name,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_FILE,
			"hint_string": "",
		})
	
	if Engine.is_editor_hint():
		ProjectSettings.save()
		editor_file_system.scan()


func _remove_plugin_settings() -> void:
	var has_changed := false
	for setting in eh_Utilities.SETTINGS:
		if ProjectSettings.has_setting(setting):
			ProjectSettings.set_setting(setting, null)
			has_changed = true
	
	for data in PATH_AUTOLOADS:
		var autoload_setting = eh_Utilities.SETTING_AUTOLOADS_BASE.path_join(data[0])
		if ProjectSettings.has_setting(autoload_setting):
			ProjectSettings.set_setting(autoload_setting, null)
			has_changed = true
	
	if has_changed:
		ProjectSettings.save()
		editor_file_system.scan()

func _on_project_settings_changed() -> void:
	_update_plugin_integrations()
	_update_autoloads()


func _update_plugin_integrations() -> void:
	const PATH_INTEGRATIONS = "res://addons/eh_jogos.utilities/integrations/"
	var plugin_integrations := DirAccess.get_directories_at(PATH_INTEGRATIONS)
	var has_changed := false
	for plugin_name in plugin_integrations:
		var ignore_path := PATH_INTEGRATIONS.path_join(plugin_name).path_join(".gdignore")
		if editor_interface.is_plugin_enabled(plugin_name):
			if FileAccess.file_exists(ignore_path):
				DirAccess.remove_absolute(ignore_path)
				has_changed = true
		else:
			if not FileAccess.file_exists(ignore_path):
				var file := FileAccess.open(ignore_path, FileAccess.WRITE)
				file.store_string("")
				has_changed = true
	
	if has_changed:
		editor_file_system.scan()

####### END OF Project Settings -------------------------------------------------------------------

####### Autoloads ---------------------------------------------------------------------------------

func _add_autoloads() -> void:
	for autoload_data in PATH_AUTOLOADS:
		var autoload_name = autoload_data[0]
		if not ProjectSettings.has_setting("autoload/%s"%[autoload_name]):
			var path = eh_Utilities.PATH_AUTOLOADS_FOLDER.path_join(autoload_data[1])
			add_autoload_singleton(autoload_name, path)


func _remove_autoloads() -> void:
	for autoload_data in PATH_AUTOLOADS:
		var autoload_name = autoload_data[0]
		if ProjectSettings.has_setting("autoload/%s"%[autoload_name]):
			var original_path := \
					eh_Utilities.PATH_AUTOLOADS_FOLDER.path_join(autoload_data[1]) as String
			var current_path := \
					ProjectSettings.get_setting("autoload/%s"%[autoload_name]) as String
			
			if "*%s"%[original_path] == current_path:
				remove_autoload_singleton(autoload_name)


func _update_autoloads() -> void:
	for autoload_data in PATH_AUTOLOADS:
		var autoload_name := autoload_data[0] as String
		var settings_name := eh_Utilities.SETTING_AUTOLOADS_BASE.path_join(autoload_name)
		var settings_path := ProjectSettings.get_setting(settings_name, "") as String
		
		var autoload_enabled := "%s_enabled"%[settings_name]
		if _is_disabled_but_has_autoload(autoload_enabled, autoload_name):
			remove_autoload_singleton(autoload_name)
			ProjectSettings.set_setting(settings_name, null)
		elif _is_enabled_but_has_no_autoload(autoload_enabled, autoload_name):
			settings_path = eh_Utilities.PATH_AUTOLOADS_FOLDER.path_join(autoload_data[1])
			add_autoload_singleton(autoload_name, settings_path)
			ProjectSettings.set_setting(settings_name, settings_path)
		
		if ProjectSettings.has_setting("autoload/%s"%[autoload_name]):
			var current_path := ProjectSettings.get_setting("autoload/%s"%[autoload_name]) as String
			if "*%s"%[settings_path] != current_path:
				remove_autoload_singleton(autoload_name)
				add_autoload_singleton(autoload_name, settings_path)


func _is_disabled_but_has_autoload(enabled_setting: String, autoload_name: String) -> bool:
	var enabled := ProjectSettings.get_setting(enabled_setting, true) as bool
	var has_autoload := ProjectSettings.has_setting("autoload/%s"%[autoload_name])
	return not enabled and has_autoload


func _is_enabled_but_has_no_autoload(enabled_setting: String, autoload_name: String) -> bool:
	var enabled := ProjectSettings.get_setting(enabled_setting, true) as bool
	var has_autoload := ProjectSettings.has_setting("autoload/%s"%[autoload_name])
	return enabled and not has_autoload

####### END OF Autoloads --------------------------------------------------------------------------

####### Tool Menu items ---------------------------------------------------------------------------

func _copy_script_templates_to_project() -> void:
	const PATH_INTERNAL_TEMPLATES = "res://addons/eh_jogos.utilities/script_templates/"
	var destination := ProjectSettings.get_setting("editor/script/templates_search_path") as String
	_copy_all_files(PATH_INTERNAL_TEMPLATES, destination)


func _copy_all_files(from: String, to: String) -> void:
	var dir := DirAccess.open(from)
	if DirAccess.get_open_error() != OK:
		push_error("Could not open path. Error: %s Path: %s"%[DirAccess.get_open_error(), from])
		return
	
	dir.include_hidden = true
	var error := dir.list_dir_begin()
	if error != OK:
		push_error("Could not begin listing directory. Error: %s Path: %s"%[error, from])
		return
	
	if not dir.dir_exists(to):
		error = dir.make_dir_recursive(to)
		if error != OK:
			push_error("Destination doesn't exist and wasn't possible to create. Path: %s"%[to])
			return
	
	var current_element := dir.get_next()
	while not current_element.is_empty():
		if dir.current_is_dir():
			var new_folder := from.path_join(current_element)
			var new_destiny := to.path_join(current_element)
			_copy_all_files(new_folder, new_destiny)
		else:
			var full_source := from.path_join(current_element)
			var full_destination := to.path_join(current_element)
			print("Copying: %s to: %s"%[full_source, full_destination])
			error = dir.copy(full_source, full_destination)
			if error != OK:
				push_error("error copying file: %s"%[error])
		current_element = dir.get_next()
	
	dir.list_dir_end()

####### END OF Tool Menu items --------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
