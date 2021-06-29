# Write your doc string for this file here
class_name eh_DirectoryHelpers
extends Reference

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

static func list_dir(path, omit_first_print: = false) -> void:
	if not omit_first_print:
		print("\nPRINTING FOLDER: %s"%[path])
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true, true)
	var next = dir.get_next()
	while next != "":
		print(next)
		if dir.current_is_dir():
			list_dir("%s/%s"%[path, next], true)
		next = dir.get_next()


static func load_from_folder_to_dict(
		folder_path: String, target_dict: Dictionary, type_hint: String = ""
	) -> void:
	var dir: = Directory.new()
	dir.open(folder_path)
	dir.list_dir_begin(true)
	var next: = dir.get_next()
	while next != "":
		if not dir.current_is_dir():
			var item = load(folder_path + next)
			if type_hint != "" and not item.is_class(type_hint):
				next = dir.get_next()
				continue
			
			var key: = next.replace(".%s"%[item.resource_path.get_extension()], "")
			target_dict[key] = item
		else:
			load_from_folder_to_dict(folder_path, target_dict, type_hint)
		
		next = dir.get_next()
	dir.list_dir_end()

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
