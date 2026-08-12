class_name DamageData
extends RefCounted

enum DamageType { PHYSICAL = 1, FIRE = 2, ICE = 4, LIGHTNING = 8, POISON = 16 }

var amount: int
var damage_types: int
var source: Node2D
var knockback: Vector2
var hit_stop_seconds: float


func _init(
	p_amount: int,
	p_source: Node2D,
	p_knockback: Vector2 = Vector2.ZERO,
	p_hit_stop_seconds: float = 0.0,
	p_damage_types: int = DamageType.PHYSICAL,
) -> void:
	amount = p_amount
	source = p_source
	knockback = p_knockback
	hit_stop_seconds = p_hit_stop_seconds
	damage_types = p_damage_types
