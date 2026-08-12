extends Node

signal state_changed

const CURRENT_SCHEMA_VERSION: int = 1

var session_started_at: String = ""
var _state: Dictionary = {}


func _ready() -> void:
	session_started_at = Time.get_datetime_string_from_system(true)
	reset_to_defaults(false)


func reset_to_defaults(announce: bool = true) -> void:
	_state = _make_default_state()
	if announce:
		state_changed.emit()
		EventBus.game_state_reset.emit()


func snapshot() -> Dictionary:
	return _state.duplicate(true)


func snapshot_for_save() -> Dictionary:
	_state[&"updated_at"] = Time.get_datetime_string_from_system(true)
	return snapshot()


func replace_from_save(saved_state: Dictionary) -> void:
	_state = _normalize_state(saved_state)
	state_changed.emit()


func set_world_flag(flag_id: StringName, value: Variant) -> void:
	var world: Dictionary = _state[&"world"]
	var flags: Dictionary = world[&"flags"]
	flags[flag_id] = value
	state_changed.emit()


func get_world_flag(flag_id: StringName, default_value: Variant = false) -> Variant:
	var world: Dictionary = _state.get(&"world", {})
	var flags: Dictionary = world.get(&"flags", {})
	return flags.get(flag_id, default_value)


func _make_default_state() -> Dictionary:
	return {
		&"schema_version": CURRENT_SCHEMA_VERSION,
		&"updated_at": Time.get_datetime_string_from_system(true),
		&"player": {
			&"level": 1,
			&"experience": 0,
			&"health": 100,
			&"stats": {},
			&"weapon_id": "starter_sword",
			&"weapon_progress": {},
			&"equipped_shards": [],
			&"inventory": [],
		},
		&"location": {
			&"zone_id": "foundation",
			&"checkpoint_id": "start",
		},
		&"world": {
			&"opened_ids": [],
			&"defeated_ids": [],
			&"quest_states": {},
			&"flags": {},
		},
	}


func _normalize_state(saved_state: Dictionary) -> Dictionary:
	var defaults: Dictionary = _make_default_state()
	var player: Dictionary = saved_state.get(&"player", {})
	var location: Dictionary = saved_state.get(&"location", {})
	var world: Dictionary = saved_state.get(&"world", {})
	var default_player: Dictionary = defaults[&"player"]
	var default_location: Dictionary = defaults[&"location"]
	var default_world: Dictionary = defaults[&"world"]

	return {
		&"schema_version": CURRENT_SCHEMA_VERSION,
		&"updated_at": str(saved_state.get(&"updated_at", defaults[&"updated_at"])),
		&"player": {
			&"level": maxi(1, int(player.get(&"level", default_player[&"level"]))),
			&"experience": maxi(0, int(player.get(&"experience", default_player[&"experience"]))),
			&"health": maxi(0, int(player.get(&"health", default_player[&"health"]))),
			&"stats": _dictionary_or_default(player.get(&"stats"), default_player[&"stats"]),
			&"weapon_id": str(player.get(&"weapon_id", default_player[&"weapon_id"])),
			&"weapon_progress": _dictionary_or_default(player.get(&"weapon_progress"), default_player[&"weapon_progress"]),
			&"equipped_shards": _array_or_default(player.get(&"equipped_shards"), default_player[&"equipped_shards"]),
			&"inventory": _array_or_default(player.get(&"inventory"), default_player[&"inventory"]),
		},
		&"location": {
			&"zone_id": str(location.get(&"zone_id", default_location[&"zone_id"])),
			&"checkpoint_id": str(location.get(&"checkpoint_id", default_location[&"checkpoint_id"])),
		},
		&"world": {
			&"opened_ids": _array_or_default(world.get(&"opened_ids"), default_world[&"opened_ids"]),
			&"defeated_ids": _array_or_default(world.get(&"defeated_ids"), default_world[&"defeated_ids"]),
			&"quest_states": _dictionary_or_default(world.get(&"quest_states"), default_world[&"quest_states"]),
			&"flags": _dictionary_or_default(world.get(&"flags"), default_world[&"flags"]),
		},
	}


func _dictionary_or_default(value: Variant, default_value: Dictionary) -> Dictionary:
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	return default_value.duplicate(true)


func _array_or_default(value: Variant, default_value: Array) -> Array:
	if value is Array:
		return (value as Array).duplicate(true)
	return default_value.duplicate(true)
