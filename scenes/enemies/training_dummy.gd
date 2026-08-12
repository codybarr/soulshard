extends Node2D

const MAX_HEALTH: int = 60

@onready var hurtbox: Hurtbox = $Hurtbox

var health: int = MAX_HEALTH
var _flash_tween: Tween
var _knockback_tween: Tween
var _is_targeted: bool = false


func _ready() -> void:
	hurtbox.hit_received.connect(_on_hit_received)
	queue_redraw()


func set_targeted(value: bool) -> void:
	_is_targeted = value
	queue_redraw()


func take_damage(damage: DamageData) -> void:
	if health <= 0:
		return
	health = maxi(0, health - damage.amount)
	_flash_hit()
	_apply_knockback(damage.knockback)
	queue_redraw()
	if health == 0:
		await get_tree().create_timer(1.0).timeout
		health = MAX_HEALTH
		queue_redraw()


func _on_hit_received(_damage: DamageData) -> void:
	pass


func _flash_hit() -> void:
	if _flash_tween != null:
		_flash_tween.kill()
	modulate = Color("fff0b0")
	_flash_tween = create_tween()
	_flash_tween.tween_property(self, "modulate", Color.WHITE, 0.14)


func _apply_knockback(knockback: Vector2) -> void:
	if _knockback_tween != null:
		_knockback_tween.kill()
	var origin := position
	_knockback_tween = create_tween()
	_knockback_tween.tween_property(self, "position", origin + knockback.normalized() * 12.0, 0.06)
	_knockback_tween.tween_property(self, "position", origin, 0.13)


func _draw() -> void:
	var ratio: float = float(health) / float(MAX_HEALTH)
	draw_circle(Vector2(0, 8), 13, Color(0.0, 0.0, 0.0, 0.3))
	draw_rect(Rect2(-10, -20, 20, 30), Color("a85b42"))
	draw_circle(Vector2(0, -23), 10, Color("d18b5f"))
	draw_line(Vector2(-13, -34), Vector2(13, -34), Color("071113"), 4)
	if _is_targeted:
		draw_arc(Vector2(0, -5), 25.0, 0.0, TAU, 24, Color("f6d66d"), 2.0)
	draw_rect(Rect2(-20, -47, 40, 5), Color("071113"))
	draw_rect(Rect2(-19, -46, 38 * ratio, 3), Color("81d6aa") if health > 0 else Color("e88962"))
