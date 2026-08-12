class_name TargetingController
extends Node

signal target_changed(target: Node2D)

@export var target_range: float = 360.0

var _target: Node2D
@onready var owner_body: Node2D = get_parent() as Node2D


func _physics_process(_delta: float) -> void:
	if _target != null and not _is_valid_target(_target):
		_set_target(null)
	if _target == null:
		_set_target(_closest_target())
	if Input.is_action_just_pressed(&"target_previous"):
		_cycle_target(-1)
	elif Input.is_action_just_pressed(&"target_next"):
		_cycle_target(1)


func get_target() -> Node2D:
	return _target


func _cycle_target(direction: int) -> void:
	var candidates := _targets_in_range()
	if candidates.is_empty():
		_set_target(null)
		return
	var current_index: int = candidates.find(_target)
	var next_index: int = 0 if current_index < 0 else posmod(current_index + direction, candidates.size())
	_set_target(candidates[next_index])


func _closest_target() -> Node2D:
	var nearest: Node2D
	var nearest_distance_squared: float = INF
	for candidate in _targets_in_range():
		var distance_squared: float = owner_body.global_position.distance_squared_to(candidate.global_position)
		if distance_squared < nearest_distance_squared:
			nearest = candidate
			nearest_distance_squared = distance_squared
	return nearest


func _targets_in_range() -> Array[Node2D]:
	var candidates: Array[Node2D] = []
	for node in get_tree().get_nodes_in_group(&"targetable"):
		var candidate := node as Node2D
		if candidate != null and _is_valid_target(candidate):
			candidates.append(candidate)
	candidates.sort_custom(func(a: Node2D, b: Node2D) -> bool:
		return owner_body.global_position.angle_to_point(a.global_position) < owner_body.global_position.angle_to_point(b.global_position)
	)
	return candidates


func _is_valid_target(candidate: Node2D) -> bool:
	return is_instance_valid(candidate) and candidate.is_in_group(&"targetable") and owner_body.global_position.distance_to(candidate.global_position) <= target_range


func _set_target(next_target: Node2D) -> void:
	if _target == next_target:
		return
	if is_instance_valid(_target) and _target.has_method(&"set_targeted"):
		_target.call(&"set_targeted", false)
	_target = next_target
	if is_instance_valid(_target) and _target.has_method(&"set_targeted"):
		_target.call(&"set_targeted", true)
	target_changed.emit(_target)
