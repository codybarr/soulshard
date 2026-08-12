class_name FireballData
extends Resource

@export var id: StringName = &"fireball"
@export var display_name: String = "Fireball"
@export_range(1, 999, 1) var damage: int = 18
@export var target_range: float = 360.0
@export var projectile_speed: float = 420.0
@export var homing_turn_rate: float = 9.0
@export var max_travel_distance: float = 520.0
@export var knockback_force: float = 220.0
@export var hit_stop_seconds: float = 0.04
