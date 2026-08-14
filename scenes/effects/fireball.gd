class_name FireballProjectile
extends Area2D

@export var data: FireballData

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var _target: Node2D
var _direction: Vector2 = Vector2.RIGHT
var _source: Node2D
var _origin: Vector2
var _spent: bool = false


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	_origin = global_position
	queue_redraw()


func launch(target: Node2D, source: Node2D, direction: Vector2) -> void:
	_target = target
	_source = source
	_direction = direction.normalized()
	_origin = global_position


func _physics_process(delta: float) -> void:
	if _spent or data == null:
		return
	if not _is_live_target():
		queue_free()
		return
	var desired_direction := global_position.direction_to(_target.global_position)
	_direction = _direction.slerp(desired_direction, minf(1.0, data.homing_turn_rate * delta)).normalized()
	rotation = _direction.angle()
	global_position += _direction * data.projectile_speed * delta
	if global_position.distance_to(_origin) >= data.max_travel_distance:
		queue_free()


func _is_live_target() -> bool:
	if not is_instance_valid(_target):
		return false
	if _target.has_method(&"is_targetable"):
		return _target.call(&"is_targetable")
	return true


func _on_area_entered(area: Area2D) -> void:
	if _spent or not area is Hurtbox:
		return
	_spent = true
	var hurtbox := area as Hurtbox
	var damage := DamageData.new(data.damage, _source, _direction * data.knockback_force, data.hit_stop_seconds)
	hurtbox.receive_hit(damage)
	collision_shape.set_deferred(&"disabled", true)
	queue_free()


func _draw() -> void:
	draw_circle(Vector2(-8, 0), 7, Color(0.96, 0.3, 0.12, 0.16))
	draw_circle(Vector2(-4, 0), 5, Color("e85b3f"))
	draw_circle(Vector2.ZERO, 5, Color("f6d66d"))
	draw_circle(Vector2(1, -1), 2, Color("fff1b0"))
