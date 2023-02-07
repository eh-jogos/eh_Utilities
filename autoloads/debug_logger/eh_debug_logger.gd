extends Node

## Class to create debug logs in csv format that can be easier to filter through and give detailed
## information without cluttering the output panel with prints. 
## [br][br]
## Originally from quiver's beat em up template repository:
## https://github.com/quiver-dev/template-beat-em-up/tree/main/addons/quiver.beat_em_up/utilities/helpers/autoload/background_loader
## [br][br]
## It is set up as an autoload automatically by the plugin script. It will start a new log 
## automatically as soon as the Autoload is ready when the game runs. To log messages
## simply do [code]eh_DebugLogger.log_message(PackedStringArray)[/code] from anywhere in your code.
## See [method log_message] for more details about usage.
## [br][br]
## So that it doesn't use too much resources by writing to disk on every [method log_message] call 
## it will keep messages in [member _current_log] and flush then to disk every 30 seconds. It will 
## also try to flush any remaining log to fisk on [code]_exit_tree()[/code], but that depends on 
## how the game is closed and might not succesfully do so on crashes.
## [br][br]
## Values for maximum number of logs kept on disk and wait time to flush log history to diek can be 
## tweaked on the autoload scene.

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const LOG_FOLDER = "user://debug_log/"
## file name format will be YYYY-MM-DDTHH-MM-SS_debug_session.csv
const LOG_FILE = LOG_FOLDER+"%s_debug_session.csv"
## file name format will be YYYY-MM-DDTHH-MM-SS_session.csv
const RELEASE_LOG_FILE = LOG_FOLDER+"%s_session.csv"

#--- public variables - order: export > normal var > onready --------------------------------------

## Max log files that will be kept in log folder.
@export_range(0,1,1,"or_greater") var max_logs := 5

#--- private variables - order: export > normal var > onready -------------------------------------

var _current_log := PackedStringArray()
var _current_log_file := ""

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready() -> void:
	_clear_old_logs()
	_start_new_log()


func _exit_tree() -> void:
	_flush_log_to_file()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

## Registers a new line into the log. By default each line includes the date and time of being 
## registered, the ticks in msec from game start, and then however many Strings are in the 
## [code]msg[/code] parameter, joined by ",".
func log_message(msg: PackedStringArray) -> void:
	if not _is_logging_enabled() or not _has_created_log_file():
		return
	
	var date_time := Time.get_datetime_string_from_system()
	var log_entry: = "%s,%09d,%s"%[date_time, Time.get_ticks_msec(), ",".join(msg)]
	_current_log.append(log_entry)

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _start_new_log() -> void:
	if not _is_logging_enabled():
		return
	
	var file_path = LOG_FILE if OS.has_feature("debug") else RELEASE_LOG_FILE
	var date_time := Time.get_datetime_string_from_system().replace(":", "-")
	_current_log_file = file_path%[date_time]
	
	if not DirAccess.dir_exists_absolute(LOG_FOLDER):
		DirAccess.make_dir_absolute(LOG_FOLDER)
	
	if not FileAccess.file_exists(_current_log_file):
		FileAccess.open(_current_log_file, FileAccess.WRITE)
		_current_log.append("Date,Ticks,Message")


func _clear_old_logs() -> void:
	var files := PackedStringArray()
	if DirAccess.dir_exists_absolute(LOG_FOLDER):
		var dir := DirAccess.open(LOG_FOLDER)
		if dir != null:
			files = dir.get_files()
			
			if files.size() > max_logs:
				for index in range(files.size()-max_logs+1):
					var file_path := files[index]
					dir.remove(file_path)
		else:
			push_error(
					"Could not open user://debug_log/ Error Code: %s"%[
					DirAccess.get_open_error()
			])


func _flush_log_to_file() -> void:
	if _current_log.is_empty():
		return
	
	var file := FileAccess.open(_current_log_file, FileAccess.READ_WRITE)
	if file != null:
		file.seek_end()
		file.store_string("\n".join(_current_log) + "\n")
		_current_log.clear()
	else:
		push_error("Unable to create file at: %s | Error: %s"%[
				_current_log_file, FileAccess.get_open_error()
		])


func _is_logging_enabled() -> bool:
	return ProjectSettings.get_setting(eh_Utilities.SETTING_LOGGING_ENABLED)


func _has_created_log_file() -> bool:
	return not _current_log_file.is_empty()


func _on_flush_log_timer_timeout() -> void:
	_flush_log_to_file()

### -----------------------------------------------------------------------------------------------
