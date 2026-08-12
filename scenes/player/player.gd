class_name PlayerController
extends CharacterBody2D

signal facing_changed(direction: Vector2)
signal presentation_state_changed(state: StringName)
signal attack_landed(attack: AttackData, damage: DamageData, target: Node2D)

const PRESENTATION_IDLE: StringName = &"idle"
const PRESENTATION_MOVE: StringName = &"move"
const PRESENTATION_ATTACK: StringName = &"attack"
const PRESENTATION_HURT: StringName = &"hurt"
const PRESENTATION_DEAD: StringName = &"dead"

@export var move_speed: float = 180.0
@export var acceleration: float = 1_600.0
@export var deceleration: float = 2_000.0
@export_range(0.0, 1.0, 0.05) var attack_move_multiplier: float = 0.55
@export var combo_attacks: Array[AttackData] = []
@export var fireball_data: FireballData
@export var fireball_scene: PackedScene

@onready var weapon_visual: Node2D = %WeaponVisual
@onready var weapon_anchor_up: Marker2D = %WeaponAnchorUp
@onready var weapon_anchor_down: Marker2D = %WeaponAnchorDown
@onready var weapon_anchor_left: Marker2D = %WeaponAnchorLeft
@onready var weapon_anchor_right: Marker2D = %WeaponAnchorRight
@onready var attack_hitbox: PlayerHitbox = %AttackHitbox
@onready var targeting: TargetingController = %TargetingController

var facing: Vector2 = Vector2.DOWN
var presentation_state: StringName = PRESENTATION_IDLE
var _walk_time: float = 0.0
var _attack_index: int = -1
var _attack_elapsed: float = 0.0
var _attack_hitbox_active: bool = false
var _attack_direction: Vector2 = Vector2.DOWN
var _combo_queued: bool = false
var _hit_stop_active: bool = false


func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	attack_hitbox.landed.connect(_on_attack_landed)
	_update_weapon_pose()
	queue_redraw()


func _physics_process(delta: float) -> void:
	if presentation_state == PRESENTATION_DEAD:
		velocity = Vector2.ZERO
		return

	if _attack_index >= 0:
		_update_attack(delta)
		queue_redraw()
		return

	if Input.is_action_just_pressed(&"light_attack"):
		_start_attack(0)
		queue_redraw()
		return
	if Input.is_action_just_pressed(&"cast_spell"):
		_cast_fireball()

	_update_movement(delta)
	queue_redraw()


func _update_movement(delta: float) -> void:
	var input_direction: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	var target_velocity: Vector2 = input_direction * move_speed
	var rate: float = acceleration if not input_direction.is_zero_approx() else deceleration
	velocity = velocity.move_toward(target_velocity, rate * delta)
	move_and_slide()

	if not input_direction.is_zero_approx():
		_set_facing(input_direction.normalized())
		_walk_time += delta * 12.0
		_set_presentation_state(PRESENTATION_MOVE)
	else:
		_set_presentation_state(PRESENTATION_IDLE)


func _start_attack(index: int) -> void:
	if index < 0 or index >= combo_attacks.size():
		return
	_attack_index = index
	_attack_elapsed = 0.0
	_attack_hitbox_active = false
	_combo_queued = false
	_attack_direction = facing
	velocity = Vector2.ZERO
	_set_presentation_state(PRESENTATION_ATTACK)
	_play_sword_swing(index)


func _update_attack(delta: float) -> void:
	var attack: AttackData = combo_attacks[_attack_index]
	_attack_elapsed += delta
	# Attacks keep their original facing, but the player can strafe at reduced speed.
	# This preserves readable sword arcs while avoiding the rooted-feet feeling.
	var input_direction: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	var target_velocity: Vector2 = input_direction * move_speed * attack_move_multiplier
	var rate: float = acceleration if not input_direction.is_zero_approx() else deceleration
	velocity = velocity.move_toward(target_velocity, rate * delta)
	move_and_slide()

	if Input.is_action_just_pressed(&"light_attack"):
		_combo_queued = true

	var active_start: float = attack.windup_seconds
	var active_end: float = active_start + attack.active_seconds
	if not _attack_hitbox_active and _attack_elapsed >= active_start:
		attack_hitbox.activate(attack, _attack_direction, self)
		_attack_hitbox_active = true
	if _attack_hitbox_active and _attack_elapsed >= active_end:
		attack_hitbox.deactivate()
		_attack_hitbox_active = false
	if _attack_elapsed < attack.total_seconds():
		return

	if _combo_queued and _attack_index + 1 < combo_attacks.size():
		_start_attack(_attack_index + 1)
		return
	_finish_attack()


func _cast_fireball() -> void:
	var target := targeting.get_target()
	if target == null or fireball_data == null or fireball_scene == null:
		return
	var direction := global_position.direction_to(target.global_position)
	if direction.is_zero_approx():
		return
	_set_facing(direction)
	var fireball := fireball_scene.instantiate() as FireballProjectile
	get_tree().current_scene.add_child(fireball)
	fireball.global_position = global_position + direction * 18.0
	fireball.data = fireball_data
	fireball.launch(target, self, direction)


func _finish_attack() -> void:
	attack_hitbox.deactivate()
	_attack_index = -1
	_attack_elapsed = 0.0
	_update_weapon_pose()
	_set_presentation_state(PRESENTATION_IDLE)


func _play_sword_swing(index: int) -> void:
	_update_weapon_pose()
	var swing_direction: float = -1.0 if index % 2 == 0 else 1.0
	var start_rotation: float = facing.angle() - swing_direction * 0.9
	var end_rotation: float = facing.angle() + swing_direction * 1.15
	weapon_visual.rotation = start_rotation
	var tween := create_tween()
	tween.tween_property(weapon_visual, "rotation", end_rotation, combo_attacks[index].windup_seconds + combo_attacks[index].active_seconds)


func play_hurt() -> void:
	_finish_attack()
	_set_presentation_state(PRESENTATION_HURT)


func play_death() -> void:
	_finish_attack()
	velocity = Vector2.ZERO
	_set_presentation_state(PRESENTATION_DEAD)


func _set_facing(direction: Vector2) -> void:
	if facing.dot(direction) > 0.985:
		return
	facing = direction
	_update_weapon_pose()
	facing_changed.emit(facing)


func _update_weapon_pose() -> void:
	var anchor: Marker2D = weapon_anchor_down
	if absf(facing.x) > absf(facing.y):
		anchor = weapon_anchor_right if facing.x > 0.0 else weapon_anchor_left
	else:
		anchor = weapon_anchor_down if facing.y > 0.0 else weapon_anchor_up
	weapon_visual.position = anchor.position
	weapon_visual.rotation = facing.angle()
	weapon_visual.z_index = 1


func _on_attack_landed(damage: DamageData, target: Node2D) -> void:
	attack_landed.emit(combo_attacks[_attack_index], damage, target)
	_apply_hit_stop(damage.hit_stop_seconds)


func _apply_hit_stop(duration: float) -> void:
	if _hit_stop_active or duration <= 0.0:
		return
	_hit_stop_active = true
	Engine.time_scale = 0.0
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0
	_hit_stop_active = false


func _set_presentation_state(next_state: StringName) -> void:
	if presentation_state == next_state:
		return
	presentation_state = next_state
	presentation_state_changed.emit(presentation_state)


func _draw() -> void:
	var bob: float = sin(_walk_time) * 1.5 if presentation_state == PRESENTATION_MOVE else 0.0
	var body_center := Vector2(0.0, -3.0 + bob)
	_draw_shadow_ellipse(Vector2(0, 11), Vector2(10, 3), Color(0.0, 0.0, 0.0, 0.32))
	draw_circle(body_center + Vector2(0, 3), 10.0, Color("237d72"))
	draw_circle(body_center + Vector2(0, -6), 7.0, Color("b3f0c9"))
	draw_circle(body_center + facing * 4.0 + Vector2(0, -6), 2.5, Color("f6d66d"))
	draw_arc(body_center + Vector2(0, 3), 10.0, 0.0, TAU, 16, Color("d7f2d7"), 1.0)


func _draw_shadow_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for index: int in 17:
		var angle: float = TAU * float(index) / 16.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, color)
