extends CanvasLayer

const UPDATE_INTERVAL: float = 0.25

@onready var panel: PanelContainer = %DebugPanel
@onready var metrics_label: Label = %MetricsLabel

var _elapsed: float = UPDATE_INTERVAL


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.visible = OS.is_debug_build()
	_update_metrics()


func _process(delta: float) -> void:
	if not panel.visible:
		return
	_elapsed += delta
	if _elapsed < UPDATE_INTERVAL:
		return
	_elapsed = 0.0
	_update_metrics()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"debug_overlay") and not event.is_echo():
		panel.visible = not panel.visible
		if panel.visible:
			_update_metrics()
		get_viewport().set_input_as_handled()


func _update_metrics() -> void:
	var scene_name: String = "none"
	if get_tree().current_scene != null:
		scene_name = get_tree().current_scene.name
	var memory_mb: float = Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0
	metrics_label.text = "DEBUG  •  F3\nFPS      %d\nMEM      %.1f MB\nSCENE    %s\nSESSION  %s\nSAVE     %s" % [
		int(Performance.get_monitor(Performance.TIME_FPS)),
		memory_mb,
		scene_name,
		GameState.session_started_at,
		"present" if SaveService.has_save() else "empty",
	]
