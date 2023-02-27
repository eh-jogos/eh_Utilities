class_name eh_DirectoryHelpers
extends RefCounted

## Write your doc string for this file here

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
	
	if not DirAccess.dir_exists_absolute(path):
		push_error("Folder %s doesn't exist"%[path])
	var dir = DirAccess.open(path)
	
	dir.list_dir_begin()
	var next = dir.get_next()
	while not next.is_empty():
		print(next)
		if dir.current_is_dir():
			list_dir("%s/%s"%[path, next], true)
		next = dir.get_next()


static func load_from_folder_to_dict(
		folder_path: String, target_dict: Dictionary, type_hint: String = ""
	) -> void:
	if not DirAccess.dir_exists_absolute(folder_path):
		push_error("Folder %s doesn't exist"%[folder_path])
	
	var dir = DirAccess.open(folder_path)
	dir.list_dir_begin()
	var next: = dir.get_next()
	while not next.is_empty():
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
