extends Node

signal save_completed(save_path: String)
signal load_completed(save_path: String)
signal operation_failed(message: String)

const SAVE_PATH: String = "user://soulshard_save.json"
const TEMP_PATH: String = "user://soulshard_save.tmp"
const BACKUP_PATH: String = "user://soulshard_save.bak"


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func get_save_path() -> String:
	return SAVE_PATH


func save_game() -> Error:
	var save_data: Dictionary = GameState.snapshot_for_save()
	var json_text: String = JSON.stringify(save_data, "\t", true, false)
	var temp_file: FileAccess = FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if temp_file == null:
		return _fail("Could not open the temporary save file: %s" % error_string(FileAccess.get_open_error()), FileAccess.get_open_error())

	temp_file.store_string(json_text)
	temp_file.flush()
	temp_file.close()

	var temp_result: Dictionary = _read_save_file(TEMP_PATH)
	if not temp_result[&"ok"]:
		_remove_if_present(TEMP_PATH)
		return _fail("Save verification failed: %s" % temp_result[&"message"], ERR_FILE_CORRUPT)

	var absolute_save: String = ProjectSettings.globalize_path(SAVE_PATH)
	var absolute_temp: String = ProjectSettings.globalize_path(TEMP_PATH)
	var absolute_backup: String = ProjectSettings.globalize_path(BACKUP_PATH)

	if FileAccess.file_exists(SAVE_PATH):
		_remove_if_present(BACKUP_PATH)
		var backup_error: Error = DirAccess.copy_absolute(absolute_save, absolute_backup)
		if backup_error != OK:
			_remove_if_present(TEMP_PATH)
			return _fail("Could not create save backup: %s" % error_string(backup_error), backup_error)

		var remove_error: Error = DirAccess.remove_absolute(absolute_save)
		if remove_error != OK:
			_remove_if_present(TEMP_PATH)
			return _fail("Could not replace existing save: %s" % error_string(remove_error), remove_error)

	var rename_error: Error = DirAccess.rename_absolute(absolute_temp, absolute_save)
	if rename_error != OK:
		if FileAccess.file_exists(BACKUP_PATH):
			DirAccess.copy_absolute(absolute_backup, absolute_save)
		return _fail("Could not finalize save: %s" % error_string(rename_error), rename_error)

	save_completed.emit(SAVE_PATH)
	EventBus.game_saved.emit(SAVE_PATH)
	return OK


func load_game() -> Error:
	var result: Dictionary = _read_save_file(SAVE_PATH)
	var loaded_path: String = SAVE_PATH
	if not result[&"ok"] and FileAccess.file_exists(BACKUP_PATH):
		result = _read_save_file(BACKUP_PATH)
		loaded_path = BACKUP_PATH

	if not result[&"ok"]:
		var code: Error = ERR_FILE_NOT_FOUND if not has_save() else ERR_FILE_CORRUPT
		return _fail(str(result[&"message"]), code)

	var data: Dictionary = result[&"data"]
	var migrated: Dictionary = _migrate_to_current(data)
	if migrated.is_empty():
		return _fail("Save schema is newer than this build or could not be migrated.", ERR_INVALID_DATA)
	if not _has_required_shape(migrated):
		return _fail("Save data is missing required player, location, or world sections.", ERR_INVALID_DATA)

	GameState.replace_from_save(migrated)
	load_completed.emit(loaded_path)
	EventBus.game_loaded.emit(loaded_path)
	return OK


func _read_save_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {&"ok": false, &"message": "No local save exists yet.", &"data": {}}

	var save_file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if save_file == null:
		return {
			&"ok": false,
			&"message": "Could not open %s: %s" % [path, error_string(FileAccess.get_open_error())],
			&"data": {},
		}

	var json_text: String = save_file.get_as_text()
	save_file.close()
	var json: JSON = JSON.new()
	var parse_error: Error = json.parse(json_text)
	if parse_error != OK:
		return {
			&"ok": false,
			&"message": "Invalid JSON at line %d: %s" % [json.get_error_line(), json.get_error_message()],
			&"data": {},
		}
	if not json.data is Dictionary:
		return {&"ok": false, &"message": "Save root must be a dictionary.", &"data": {}}

	return {&"ok": true, &"message": "", &"data": json.data as Dictionary}


func _migrate_to_current(source: Dictionary) -> Dictionary:
	var data: Dictionary = source.duplicate(true)
	var version: int = int(data.get(&"schema_version", 0))
	if version > GameState.CURRENT_SCHEMA_VERSION:
		return {}

	while version < GameState.CURRENT_SCHEMA_VERSION:
		match version:
			0:
				# Pre-release saves had the current shape but no explicit contract.
				data[&"schema_version"] = 1
				version = 1
			_:
				return {}
	return data


func _has_required_shape(data: Dictionary) -> bool:
	return (
		data.get(&"player") is Dictionary
		and data.get(&"location") is Dictionary
		and data.get(&"world") is Dictionary
	)


func _remove_if_present(path: String) -> void:
	if FileAccess.file_exists(path):
		var remove_error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
		if remove_error != OK:
			push_warning("Could not remove %s: %s" % [path, error_string(remove_error)])


func _fail(message: String, code: Error) -> Error:
	operation_failed.emit(message)
	EventBus.save_failed.emit(message)
	push_error(message)
	return code
