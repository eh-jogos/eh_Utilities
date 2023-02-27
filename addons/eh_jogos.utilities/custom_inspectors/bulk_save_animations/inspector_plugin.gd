extends EditorInspectorPlugin

## Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const BULK_SAVE_PANEL = preload("res://addons/eh_jogos.utilities/custom_inspectors/bulk_save_animations/bulk_save_control.tscn")

#--- public variables - order: export > normal var > onready --------------------------------------

var parent_plugin: EditorPlugin = null

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _can_handle(object) -> bool:
	return object is AnimationPlayer


func _parse_begin(object: Object) -> void:
	var bulk_save_panel := BULK_SAVE_PANEL.instantiate()
	bulk_save_panel.animation_player = object as AnimationPlayer
	bulk_save_panel.editor_interface = parent_plugin.get_editor_interface()
	add_custom_control(bulk_save_panel)

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
