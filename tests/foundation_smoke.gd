extends Node

const SAVE_FILES: Array[String] = [
	"user://soulshard_save.json",
	"user://soulshard_save.tmp",
	"user://soulshard_save.bak",
]

var _failed: bool = false
var _original_files: Dictionary = {}


func _ready() -> void:
	_capture_save_files()
	var defaults: Dictionary = GameState.snapshot()
	_check(defaults.get(&"schema_version") == 1, "default schema version")
	_check(defaults.get(&"player") is Dictionary, "default player section")

	GameState.set_world_flag(&"foundation_smoke_test", true)
	var save_error: Error = SaveService.save_game()
	_check(save_error == OK, "save_game returns OK")

	GameState.set_world_flag(&"foundation_smoke_test", false)
	var load_error: Error = SaveService.load_game()
	_check(load_error == OK, "load_game returns OK")
	_check(GameState.get_world_flag(&"foundation_smoke_test", false) == true, "saved state round-trips")

	_restore_save_files()
	if _failed:
		get_tree().quit(1)
	else:
		print("Soulshard foundation smoke test passed.")
		get_tree().quit(0)


func _capture_save_files() -> void:
	for path: String in SAVE_FILES:
		if not FileAccess.file_exists(path):
			_original_files[path] = null
			continue
		var file: FileAccess = FileAccess.open(path, FileAccess.READ)
		_original_files[path] = file.get_buffer(file.get_length())
		file.close()


func _restore_save_files() -> void:
	for path: String in SAVE_FILES:
		var absolute_path: String = ProjectSettings.globalize_path(path)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(absolute_path)
		var original: Variant = _original_files.get(path)
		if original is PackedByteArray:
			var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
			file.store_buffer(original as PackedByteArray)
			file.close()


func _check(condition: bool, label: String) -> void:
	if condition:
		return
	_failed = true
	push_error("Smoke test failed: %s" % label)
