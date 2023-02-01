extends EditorInspectorPlugin

# Write your doc string for this file here

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const CustomResourceProperty = preload(
		"res://addons/eh_jogos.utilities/custom_inspectors/custom_resource/"
		 + "custom_resource_property.gd"
)

const HINT_STRING_PREFIX = "CustomResource"

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func can_handle(object: Object) -> bool:
	return object is Node or object is Resource


func parse_property(
		object: Object, 
		type: int, 
		path: String, 
		hint: int, 
		hint_text: String, 
		usage: int
) -> bool:
	var replace_built_in := false
	if hint == PROPERTY_HINT_RESOURCE_TYPE and hint_text.begins_with(HINT_STRING_PREFIX):
		var str_dict := hint_text.replace(HINT_STRING_PREFIX, "")
		var options_dict := str2var(str_dict) as Dictionary
		if options_dict.has("type"):
			var custom_picker := CustomResourceProperty.new()
			custom_picker.options_dict = options_dict
			add_property_editor(path, custom_picker)
			replace_built_in = true
	
	return replace_built_in

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
