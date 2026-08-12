class_name AttackData
extends Resource

@export var id: StringName = &"attack"
@export var display_name: String = "Attack"
@export_range(1, 999, 1) var damage: int = 10
@export var windup_seconds: float = 0.12
@export var active_seconds: float = 0.10
@export var recovery_seconds: float = 0.22
@export var hitbox_offset: Vector2 = Vector2(25, 0)
@export var hitbox_size: Vector2 = Vector2(28, 22)
@export var knockback_force: float = 180.0
@export var hit_stop_seconds: float = 0.035


func total_seconds() -> float:
	return windup_seconds + active_seconds + recovery_seconds
