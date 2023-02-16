@tool
extends VBoxContainer

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const META_VALUE = "base_export_path"
const DIALOG_MIN_SIZE = Vector2(900,600)

#--- public variables - order: export > normal var > onready --------------------------------------

var animation_player: AnimationPlayer = null:
	set(value):
		animation_player = value
		_read_anim_libraries()
		
		if not is_inside_tree():
			await ready
		
		if animation_player.has_meta(META_VALUE):
			_base_export_path = animation_player.get_meta(META_VALUE)
			_line_edit.text = _base_export_path

#--- private variables - order: export > normal var > onready -------------------------------------

var _base_export_path := "":
	set(value):
		_base_export_path = value
		_validade_export_path()
		
		if animation_player != null:
			animation_player.set_meta(META_VALUE, _base_export_path)

@onready var _line_edit := $BaseFolderLine/Editable/LineEdit as LineEdit
@onready var _export_button: Button = $ExportButton

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
	print("I'll read all the anim libraries here and setup the libraries list of checkbox")
	pass


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
	
	print("This will show warnings if export path is wrong")


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
	print("Exporting animations to %s"%[_base_export_path])
	pass

### -----------------------------------------------------------------------------------------------
