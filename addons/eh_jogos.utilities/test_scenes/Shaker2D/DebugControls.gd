# Write your doc string for this file here
extends VBoxContainer

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

export var _path_shaker: NodePath = NodePath("")

onready var _shaker: Node = get_node(_path_shaker)

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	pass

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _on_TimeScaleSlider_value_changed(value: float) -> void:
	Engine.time_scale = value


func _on_TraumaSmall_pressed() -> void:
	_shaker.add_trauma(0.3)


func _on_TraumaMedium_pressed() -> void:
	_shaker.add_trauma(0.6)


func _on_TraumaBig_pressed() -> void:
	_shaker.add_trauma(1.0)

### -----------------------------------------------------------------------------------------------
