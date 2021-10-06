# Write your doc string for this file here
tool
class_name DebugPrintPanel
extends PanelContainer

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

export var text_color: Color = Color.white

#--- private variables - order: export > normal var > onready -------------------------------------

var _print_dict: Dictionary = {}
var _horizontral_size: = 0.0

onready var _list: VBoxContainer = $VBoxContainer

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	pass

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

static func print_value(node: Node, key: String, value, max_size: float = INF) -> void:
	node.get_tree().call_group("debug_print", "_update_size", max_size)
	node.get_tree().call_group("debug_print", "_print_value", key, value)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _print_value(key: String, value) -> void:
	var treated_key = key.replace("/", "_").replace(" ", "_").replace(".","_").replace("@", "_AT_")
	_print_dict[key] = value
	if not _list.has_node(treated_key):
		var label = Label.new()
		label.name = treated_key
		label.add_color_override("font_color", text_color)
		if _horizontral_size != 0:
			label.autowrap = true
		_list.add_child(label, true)
		call_deferred("_update_text", label, key, value)
	else:
		var label: Label = _list.get_node(treated_key)
		_update_text(label, key, value)


func _update_text(label: Label, key: String, value) -> void:
	label.text = "%s: %s [%s]"%[key, value, OS.get_ticks_msec()]


func _on_ClearButton_pressed() -> void:
	_print_dict.clear()
	for child in _list.get_children():
		_list.remove_child(child)
		child.queue_free()
	_reset_size()


func _reset_size() -> void:
	margin_left = -_horizontral_size
	margin_top = 0


func _update_size(max_size: float) -> void:
	if max_size != INF and max_size != _horizontral_size:
		_horizontral_size = max_size
		_reset_size()

### -----------------------------------------------------------------------------------------------
