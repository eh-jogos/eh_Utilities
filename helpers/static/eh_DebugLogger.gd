# Write your doc string for this file here
class_name eh_DebugLogger
extends Reference

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const LOG_FILE = "user://debug_session.log"
const RELEASE_LOG_FILE = "res://session.log"

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

static func start_new_log() -> void:
	if not ProjectSettings.get_setting(eh_UtilitiesEditorPlugin.SETTING_LOGGING_ENABLED):
		return
	
	var file_path = LOG_FILE if OS.has_feature("debug") else RELEASE_LOG_FILE
	
	var file = File.new()
	file.open(file_path, File.WRITE)
	file.store_string("")
	file.close()


static func log_message(msg: String) -> void:
	if not ProjectSettings.get_setting(eh_UtilitiesEditorPlugin.SETTING_LOGGING_ENABLED):
		return
	
	var date_time: = get_date_time_string()
	var log_entry: = "%s - %09d - %s \n"%[date_time, OS.get_ticks_msec(), msg]
	var file_path = LOG_FILE if OS.has_feature("debug") else RELEASE_LOG_FILE
	
	var file = File.new()
	file.open(file_path, File.READ_WRITE)
	
	var contents: String = file.get_as_text()
	contents += log_entry
	file.store_string(contents)
	
	file.close()


static func get_date_time_string() -> String:
	var date_time: = OS.get_datetime()
	var date_time_string: = "{year}-{month}-{day} {hour}-{minute}-{second}".format({
			year = date_time.year,
			month = "%02d"%[date_time.month],
			day = "%02d"%[date_time.day],
			hour = "%02d"%[date_time.hour],
			minute = "%02d"%[date_time.minute],
			second = "%02d"%[date_time.second],
	})
	return date_time_string

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
