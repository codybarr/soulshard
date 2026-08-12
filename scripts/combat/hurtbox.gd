class_name Hurtbox
extends Area2D

signal hit_received(damage: DamageData)


func receive_hit(damage: DamageData) -> void:
	hit_received.emit(damage)
	var recipient: Node = get_parent()
	if recipient.has_method(&"take_damage"):
		recipient.call(&"take_damage", damage)
