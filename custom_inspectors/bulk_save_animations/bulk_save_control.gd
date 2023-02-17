@tool
extends VBoxContainer

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const META_VALUE = "base_export_path"
const DIALOG_MIN_SIZE = Vector2(900,600)
const GLOBAL_ANIM_LIBRARY_NAME = "[Global]"

#--- public variables - order: export > normal var > onready --------------------------------------

var animation_player: AnimationPlayer = null:
	set(value):
		animation_player = value
		
		if not is_inside_tree():
			await ready
		
		_read_anim_libraries()
		if animation_player.has_meta(META_VALUE):
			_base_export_path = animation_player.get_meta(META_VALUE)
			_line_edit.text = _base_export_path

var editor_interface: EditorInterface = null

#--- private variables - order: export > normal var > onready -------------------------------------

var _anim_libraries_to_export := {}

var _base_export_path := "":
	set(value):
		_base_export_path = value
		_validade_export_path()
		
		if animation_player != null:
			animation_player.set_meta(META_VALUE, _base_export_path)

@onready var _line_edit := $BaseFolderLine/Editable/LineEdit as LineEdit
@onready var _export_button: Button = $ExportButton
@onready var _libraries_list: VBoxContainer = $LibraryPicker/LibrariesList

@onready var _list_errors: VBoxContainer = $PathErrors
@onready var _error_empty: Label = $PathErrors/ErrorEmpty
@onready var _error_res: Label = $PathErrors/ErrorRes

@onready var _list_warnings: VBoxContainer = $PathWarnings
@onready var _warn_create: Label = $PathWarnings/WarnCreate
@onready var _warn_overwrite: Label = $PathWarnings/WarnOverwrite

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	pass

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _read_anim_libraries() -> void:
	var anim_library_list := animation_player.get_animation_library_list()
	for library_name in anim_library_list:
		if library_name.is_empty():
			library_name = GLOBAL_ANIM_LIBRARY_NAME
		_anim_libraries_to_export[library_name] = true
		
		var new_checkbox := CheckBox.new()
		new_checkbox.text = library_name
		new_checkbox.button_pressed = true
		_libraries_list.add_child(new_checkbox, true)
		
		new_checkbox.toggled.connect(_toggle_export_anim_library.bind(library_name))


func _toggle_export_anim_library(should_export, anim_library) -> void:
	if _anim_libraries_to_export.has(anim_library):
		_anim_libraries_to_export[anim_library] = should_export
	else:
		push_error("Could not find %s in %s"%[anim_library, _anim_libraries_to_export])


func _validade_export_path() -> void:
	_error_empty.visible = _base_export_path.is_empty()
	_error_res.visible = not _base_export_path.begins_with("res://")
	
	var has_errors := _list_errors.get_children().any(_is_control_visible)
	_list_errors.visible = has_errors
	_export_button.disabled = has_errors
	
	if not has_errors:
		var has_dir = DirAccess.dir_exists_absolute(_base_export_path)
		_warn_create.visible = not has_dir
		if has_dir:
			var files := DirAccess.get_files_at(_base_export_path)
			var directories := DirAccess.get_directories_at(_base_export_path)
			_warn_overwrite.visible = not files.is_empty() or not directories.is_empty()
		else:
			_warn_overwrite.visible = false
		
		_list_warnings.visible = _list_warnings.get_children().any(_is_control_visible)
	else:
		for child in _list_warnings.get_children():
			child.hide()
		_list_warnings.hide()


func _is_control_visible(control: Control) -> bool:
	return control.visible


func _get_export_dir_dialog() -> EditorFileDialog:
	var new_dialog := EditorFileDialog.new()
	new_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	new_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	new_dialog.title = "Select base folder to export animation files"
	new_dialog.display_mode = EditorFileDialog.DISPLAY_LIST
	new_dialog.name = "AnimationExportFolderDialog"
	new_dialog.min_size = DIALOG_MIN_SIZE
	
	return new_dialog


func _export_anim_library_and_animations(library_name: StringName, library_folder_name: String) -> void:
	var library_folder_path := _base_export_path.path_join(library_folder_name)
	_create_folder_if_necessary(library_folder_path)
	
	var anim_library := animation_player.get_animation_library(library_name)
	for anim_name in anim_library.get_animation_list():
		var animation_path := library_folder_path.path_join("%s.tres"%[anim_name])
		var animation := anim_library.get_animation(anim_name)
		animation.take_over_path(animation_path)
		ResourceSaver.save(animation, animation_path, ResourceSaver.FLAG_CHANGE_PATH)
	
	var library_file_path := _base_export_path.path_join("%s.tres"%[library_folder_name])
	anim_library.take_over_path(library_file_path)
	ResourceSaver.save(anim_library, library_file_path, ResourceSaver.FLAG_CHANGE_PATH)


# Only get's called when text is changed in the editor, not when _line_edit.text is changed by code.
func _on_line_edit_text_changed(new_text: String) -> void:
	_base_export_path = new_text


func _on_folder_dialog_pressed() -> void:
	var new_dialog := _get_export_dir_dialog()
	add_child(new_dialog, true)
	new_dialog.popup()
	
	_base_export_path = await new_dialog.dir_selected
	_line_edit.text = _base_export_path
	
	new_dialog.queue_free()


func _on_export_button_pressed() -> void:
	_create_folder_if_necessary(_base_export_path)
	
	for library_name in _anim_libraries_to_export:
		var library_folder_name := (library_name as String).to_snake_case()
		if library_name == GLOBAL_ANIM_LIBRARY_NAME:
			library_name = ""
			library_folder_name = "global_anim_library"
		
		_export_anim_library_and_animations(library_name, library_folder_name)
		editor_interface.get_resource_filesystem().scan()
		editor_interface.get_file_system_dock().navigate_to_path(_base_export_path)
		editor_interface.save_scene()


func _create_folder_if_necessary(folder_path: String) -> void:
	if not DirAccess.dir_exists_absolute(folder_path):
		DirAccess.make_dir_recursive_absolute(folder_path)

### -----------------------------------------------------------------------------------------------
