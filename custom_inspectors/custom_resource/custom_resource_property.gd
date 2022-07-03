extends EditorProperty

# Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

var CustomResourcePicker = preload(
		"res://addons/eh_jogos.utilities/custom_inspectors/custom_resource/"
		+ "custom_resource_picker.gd"
)

#--- public variables - order: export > normal var > onready --------------------------------------

var options_dict := {} setget _set_options_dict

#--- private variables - order: export > normal var > onready -------------------------------------

var _edited_object: Object = null
var _property_path: String = ""
var _property_value = null

var _picker: EditorResourcePicker = null

var _custom_type: String = ""
var _current_script_reference: Script = null

var _custom_classes_by_name := {}
var _custom_inheritance_by_class := {}

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _init() -> void:
	_populate_custom_clases()


func _ready() -> void:
	_edited_object = get_edited_object()
	_property_path = get_edited_property()
	_property_value = _edited_object.get(_property_path)
	_add_property_field()
	pass

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

func _add_property_field() -> void:
	_picker = CustomResourcePicker.new()
	_picker.edited_resource = _property_value
	add_child(_picker, true)
	_picker.set_allowed_classes(
			options_dict.type,
			_custom_classes_by_name,
			_custom_inheritance_by_class
	)
	add_focusable(_picker)
	_picker.connect("resource_changed", self, "_on_resource_picker_resource_changed")
	_picker.connect("resource_selected", self, "_on_resource_picker_resource_selected")

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _populate_custom_clases() -> void:
	var custom_classes := ProjectSettings.get_setting("_global_script_classes") as Array
	for class_dict in custom_classes:
		_custom_classes_by_name[class_dict.class] = class_dict
		if not _custom_inheritance_by_class.has(class_dict.class):
			_custom_inheritance_by_class[class_dict.class] = []
		
		if (
				not ClassDB.class_exists(class_dict.base) 
				and not _custom_inheritance_by_class.has(class_dict.base)
		):
			_custom_inheritance_by_class[class_dict.base] = []
		
		if _custom_inheritance_by_class.has(class_dict.base):
			_custom_inheritance_by_class[class_dict.base].append(class_dict.class)


func _is_script_of_reference_type(p_script: Script) -> bool:
	var value = false
	
	if p_script != null:
		value = p_script == _current_script_reference
		if not value:
			var base_script := p_script.get_base_script()
			if base_script != null:
				value = _is_script_of_reference_type(base_script)
	
	return value


func _set_options_dict(value: Dictionary) -> void:
	options_dict = value
	_custom_type = options_dict.type
	if _custom_type in _custom_classes_by_name:
		_current_script_reference = load(_custom_classes_by_name[_custom_type].path)


func _on_resource_picker_resource_changed(resource: Resource) -> void:
	if resource != null:
		var script := resource.get_script() as Script
		var is_reference_type := _is_script_of_reference_type(script)
		var new_value = resource if is_reference_type else null
		emit_changed(_property_path, new_value)
		_edited_object.property_list_changed_notify()


func _on_resource_picker_resource_selected(resource: Resource, _edit: bool) -> void:
	if resource != null:
		emit_signal("resource_selected", get_edited_property(), resource)

### -----------------------------------------------------------------------------------------------
