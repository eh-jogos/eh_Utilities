@tool
class_name eh_Debug_Label
extends Label

## Label to easily follow the values of properties or methods of any node.

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export var max_width := 0

## Node that will be used as base to access properties or methods.
@export var path_node: NodePath:
	set(value):
		path_node = value
		if is_inside_tree():
			_reference_node = get_node_or_null(path_node)
		update_configuration_warnings()

@export var properties: PackedStringArray:
	set(value):
		properties = value
		update_configuration_warnings()

@export var methods: PackedStringArray

#--- private variables - order: export > normal var > onready -------------------------------------

@onready var _reference_node := get_node_or_null(path_node)

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	if Engine.is_editor_hint():
		eh_EditorHelpers.disable_all_processing(self)
		return
	
	if max_width == 0:
		max_width = get_viewport_rect().size.x


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(_reference_node):
		push_error("invalid reference node (%s) for path: %s"%[_reference_node, path_node])
		return
	
	var messages := PackedStringArray()
	messages.append("%s"%[_reference_node.name])
	for property in properties:
		var value = _reference_node.get_indexed(property)
		var msg := _get_message_for_value(property, value)
		messages.append(msg)
	
	for method in methods:
		var value = _reference_node.call(method)
		var msg := _get_message_for_value("%s()"%[method], value)
		messages.append(msg)
	text = "\n".join(messages)
	
	if size.x > max_width:
		custom_minimum_size.x = max_width
		autowrap_mode = TextServer.AUTOWRAP_WORD


func _get_message_for_value(p_name: String, p_value: Variant) -> String:
	if p_value is float:
		p_value = "%0.2f"%[p_value]
	return "    %s: %s"%[p_name, p_value]


func _get_configuration_warnings() -> PackedStringArray:
	const WARN_PATH = "path_node must point to a valid node"
	const WARN_NOTHING_TO_DO = "Both properties and methods arrays are empty, this Debug Label"\
			+ " has nothing to show."
	var warnings := PackedStringArray()
	
	if path_node.is_empty() or _reference_node == null:
		warnings.append(WARN_PATH)
	
	if properties.is_empty() and methods.is_empty():
		warnings.append(WARN_NOTHING_TO_DO)
	
	return warnings

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
