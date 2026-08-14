class_name MeleeEnemyData
extends Resource

@export var id: StringName = &"ruin_sentinel"
@export var display_name: String = "Ruin Sentinel"
@export_range(1, 999, 1) var max_health: int = 55
@export var move_speed: float = 105.0
@export var aggro_range: float = 260.0
@export var attack_range: float = 42.0
@export var attack_damage: int = 14
@export var attack_windup_seconds: float = 0.55
@export var attack_active_seconds: float = 0.14
@export var attack_recovery_seconds: float = 0.45
@export var attack_hitbox_offset: float = 24.0
@export var attack_hitbox_size: Vector2 = Vector2(30.0, 24.0)
@export var attack_knockback_force: float = 260.0
@export var hurt_seconds: float = 0.22
@export var respawn_seconds: float = 4.0
