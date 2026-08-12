extends Control

const GRID_SIZE: float = 16.0

@onready var status_label: Label = %StatusLabel
@onready var save_button: Button = %SaveButton
@onready var load_button: Button = %LoadButton
@onready var reset_button: Button = %ResetButton


func _ready() -> void:
	resized.connect(queue_redraw)
	save_button.pressed.connect(_save_game)
	load_button.pressed.connect(_load_game)
	reset_button.pressed.connect(_reset_state)
	EventBus.game_saved.connect(_on_game_saved)
	EventBus.game_loaded.connect(_on_game_loaded)
	EventBus.save_failed.connect(_on_save_failed)
	EventBus.game_state_reset.connect(_on_game_state_reset)
	load_button.disabled = not SaveService.has_save()
	save_button.grab_focus()
	_set_status("FOUNDATION ONLINE", Color("81d6aa"))


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("071113"))
	for x: float in range(0, int(size.x) + int(GRID_SIZE), int(GRID_SIZE)):
		draw_line(Vector2(x, 0), Vector2(x, size.y), Color(0.12, 0.25, 0.23, 0.15), 1.0)
	for y: float in range(0, int(size.y) + int(GRID_SIZE), int(GRID_SIZE)):
		draw_line(Vector2(0, y), Vector2(size.x, y), Color(0.12, 0.25, 0.23, 0.15), 1.0)

	var center: Vector2 = size * Vector2(0.5, 0.43)
	draw_circle(center + Vector2(0, 18), 92.0, Color(0.025, 0.09, 0.082, 0.85))
	draw_circle(center + Vector2(0, 18), 68.0, Color(0.039, 0.145, 0.122, 0.75))
	_draw_shard(center)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"quick_save") and not event.is_echo():
		_save_game()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"quick_load") and not event.is_echo():
		_load_game()
		get_viewport().set_input_as_handled()


func _draw_shard(center: Vector2) -> void:
	var shadow: PackedVector2Array = PackedVector2Array([
		center + Vector2(-25, 59), center + Vector2(1, 72), center + Vector2(31, 56),
		center + Vector2(8, 62),
	])
	draw_colored_polygon(shadow, Color(0, 0, 0, 0.35))
	var shard: PackedVector2Array = PackedVector2Array([
		center + Vector2(0, -67), center + Vector2(31, -17), center + Vector2(18, 48),
		center + Vector2(0, 64), center + Vector2(-25, 42), center + Vector2(-32, -18),
	])
	draw_colored_polygon(shard, Color("67cfa8"))
	var light_face: PackedVector2Array = PackedVector2Array([
		center + Vector2(0, -67), center + Vector2(31, -17), center + Vector2(0, 10),
	])
	draw_colored_polygon(light_face, Color("b3f0c9"))
	var dark_face: PackedVector2Array = PackedVector2Array([
		center + Vector2(0, 10), center + Vector2(18, 48), center + Vector2(0, 64), center + Vector2(-25, 42),
	])
	draw_colored_polygon(dark_face, Color("257d72"))
	draw_polyline(shard, Color("f6d66d"), 2.0, false)
	draw_line(center + Vector2(0, -67), center + Vector2(0, 64), Color(0.9, 1, 0.85, 0.5), 1.0)


func _save_game() -> void:
	_set_status("SAVING…", Color("f6d66d"))
	SaveService.save_game()


func _load_game() -> void:
	if not SaveService.has_save():
		_set_status("NO SAVE FOUND", Color("e88962"))
		return
	_set_status("LOADING…", Color("f6d66d"))
	SaveService.load_game()


func _reset_state() -> void:
	GameState.reset_to_defaults()


func _on_game_saved(_save_path: String) -> void:
	load_button.disabled = false
	_set_status("SAVE VERIFIED", Color("81d6aa"))


func _on_game_loaded(_save_path: String) -> void:
	_set_status("STATE RESTORED", Color("81d6aa"))


func _on_save_failed(message: String) -> void:
	_set_status(message.to_upper(), Color("e88962"))


func _on_game_state_reset() -> void:
	_set_status("SESSION RESET", Color("f6d66d"))


func _set_status(message: String, color: Color) -> void:
	status_label.text = "●  %s" % message
	status_label.add_theme_color_override(&"font_color", color)
