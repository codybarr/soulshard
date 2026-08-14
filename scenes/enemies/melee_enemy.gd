class_name MeleeEnemy
extends CharacterBody2D

signal state_changed(state: StringName)
signal health_changed(current_health: int, maximum_health: int)
signal died
signal respawned

const STATE_IDLE: StringName = &"idle"
const STATE_PURSUE: StringName = &"pursue"
const STATE_TELEGRAPH: StringName = &"telegraph"
const STATE_ATTACK: StringName = &"attack"
const STATE_RECOVERY: StringName = &"recovery"
const STATE_HURT: StringName = &"hurt"
const STATE_DEAD: StringName = &"dead"

@export var data: MeleeEnemyData

@onready var hurtbox: Hurtbox = %Hurtbox
@onready var attack_hitbox: EnemyHitbox = %AttackHitbox

var state: StringName = STATE_IDLE
var health: int = 1
var facing: Vector2 = Vector2.DOWN
var _spawn_position: Vector2
var _state_elapsed: float = 0.0
var _knockback_velocity: Vector2 = Vector2.ZERO
var _target: Node2D
var _flash_tween: Tween
var _is_targeted: bool = false


func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	_spawn_position = global_position
	health = data.max_health if data != null else 1
	hurtbox.hit_received.connect(_on_hit_received)
	queue_redraw()


func _physics_process(delta: float) -> void:
	if data == null:
		return
	_state_elapsed += delta
	if state == STATE_DEAD:
		_update_dead()
		queue_redraw()
		return

	_target = _find_target()
	match state:
		STATE_IDLE:
			_update_idle()
		STATE_PURSUE:
			_update_pursue(delta)
		STATE_TELEGRAPH:
			_update_telegraph()
		STATE_ATTACK:
			_update_attack()
		STATE_RECOVERY:
			_update_recovery()
		STATE_HURT:
			_update_hurt(delta)
	queue_redraw()


func is_targetable() -> bool:
	return state != STATE_DEAD and health > 0


func set_targeted(value: bool) -> void:
	_is_targeted = value
	queue_redraw()


func take_damage(incoming_damage: DamageData) -> void:
	if state == STATE_DEAD or data == null:
		return
	health = maxi(0, health - incoming_damage.amount)
	health_changed.emit(health, data.max_health)
	_flash_hit()
	if health == 0:
		_die()
		return
	_knockback_velocity = incoming_damage.knockback
	_set_state(STATE_HURT)


func _update_idle() -> void:
	velocity = Vector2.ZERO
	if _target != null and global_position.distance_to(_target.global_position) <= data.aggro_range:
		_set_state(STATE_PURSUE)


func _update_pursue(delta: float) -> void:
	if _target == null:
		velocity = Vector2.ZERO
		_set_state(STATE_IDLE)
		return
	var to_target := global_position.direction_to(_target.global_position)
	if not to_target.is_zero_approx():
		facing = to_target
	var distance := global_position.distance_to(_target.global_position)
	if distance <= data.attack_range:
		velocity = Vector2.ZERO
		_set_state(STATE_TELEGRAPH)
		return
	if distance > data.aggro_range * 1.25:
		velocity = Vector2.ZERO
		_set_state(STATE_IDLE)
		return
	velocity = facing * data.move_speed
	move_and_slide()


func _update_telegraph() -> void:
	velocity = Vector2.ZERO
	_face_target()
	if _state_elapsed >= data.attack_windup_seconds:
		var damage := DamageData.new(data.attack_damage, self, facing * data.attack_knockback_force)
		attack_hitbox.activate(damage, facing, data.attack_hitbox_offset, data.attack_hitbox_size)
		_set_state(STATE_ATTACK)


func _update_attack() -> void:
	velocity = Vector2.ZERO
	if _state_elapsed >= data.attack_active_seconds:
		attack_hitbox.deactivate()
		_set_state(STATE_RECOVERY)


func _update_recovery() -> void:
	velocity = Vector2.ZERO
	if _state_elapsed >= data.attack_recovery_seconds:
		_set_state(STATE_PURSUE)


func _update_hurt(delta: float) -> void:
	velocity = _knockback_velocity
	move_and_slide()
	_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, data.attack_knockback_force * 8.0 * delta)
	if _state_elapsed >= data.hurt_seconds:
		_set_state(STATE_PURSUE)


func _update_dead() -> void:
	velocity = Vector2.ZERO
	if _state_elapsed >= data.respawn_seconds:
		global_position = _spawn_position
		health = data.max_health
		hurtbox.monitorable = true
		hurtbox.get_node("CollisionShape2D").set_deferred(&"disabled", false)
		respawned.emit()
		_set_state(STATE_IDLE)


func _die() -> void:
	attack_hitbox.deactivate()
	hurtbox.monitorable = false
	hurtbox.get_node("CollisionShape2D").set_deferred(&"disabled", true)
	died.emit()
	_set_state(STATE_DEAD)


func _face_target() -> void:
	if _target == null:
		return
	var direction := global_position.direction_to(_target.global_position)
	if not direction.is_zero_approx():
		facing = direction


func _find_target() -> Node2D:
	var players := get_tree().get_nodes_in_group(&"player")
	if players.is_empty():
		return null
	return players[0] as Node2D


func _on_hit_received(_damage: DamageData) -> void:
	pass


func _set_state(next_state: StringName) -> void:
	if state == next_state:
		return
	state = next_state
	_state_elapsed = 0.0
	state_changed.emit(state)


func _flash_hit() -> void:
	if _flash_tween != null:
		_flash_tween.kill()
	modulate = Color("fff0b0")
	_flash_tween = create_tween()
	_flash_tween.tween_property(self, "modulate", Color.WHITE, 0.12)


func _draw() -> void:
	var body_color := Color("7f9e74") if state != STATE_DEAD else Color("46534b")
	draw_circle(Vector2(0, 10), 14, Color(0.0, 0.0, 0.0, 0.30))
	draw_rect(Rect2(-10, -17, 20, 28), body_color)
	draw_circle(Vector2(0, -20), 10, Color("b6c4a0"))
	draw_line(Vector2(-13, -31), Vector2(13, -31), Color("263630"), 4.0)
	draw_line(Vector2(0, -6), facing * 13.0 + Vector2(0, -6), Color("f6d66d"), 2.0)
	if _is_targeted:
		draw_arc(Vector2(0, -5), 25.0, 0.0, TAU, 24, Color("f6d66d"), 2.0)
	if state == STATE_TELEGRAPH:
		draw_arc(Vector2.ZERO, data.attack_range, 0.0, TAU, 28, Color("e88962"), 2.0)
	var ratio: float = float(health) / float(data.max_health)
	draw_rect(Rect2(-20, -45, 40, 5), Color("071113"))
	draw_rect(Rect2(-19, -44, 38 * ratio, 3), Color("81d6aa") if health > 0 else Color("e88962"))
