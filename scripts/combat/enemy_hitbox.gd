class_name EnemyHitbox
extends Area2D

signal landed(damage: DamageData, target: Node2D)

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var _damage: DamageData
var _struck: Dictionary[Node2D, bool] = {}


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	deactivate()


func activate(damage: DamageData, direction: Vector2, offset: float, size: Vector2) -> void:
	_struck.clear()
	_damage = damage
	position = direction * offset
	rotation = direction.angle()
	var shape := collision_shape.shape as RectangleShape2D
	shape.size = size
	collision_shape.set_deferred(&"disabled", false)


func deactivate() -> void:
	_damage = null
	collision_shape.set_deferred(&"disabled", true)


func _on_area_entered(area: Area2D) -> void:
	if _damage == null or not area is Hurtbox:
		return
	var hurtbox := area as Hurtbox
	var target := hurtbox.get_parent() as Node2D
	if target == null or _struck.has(target):
		return
	_struck[target] = true
	hurtbox.receive_hit(_damage)
	landed.emit(_damage, target)
