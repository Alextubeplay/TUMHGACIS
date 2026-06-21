extends Node

var difficulty = 1
var shift_timer = 120.0
var amount_of_tasks = 3
var completed_tasks = 0:
	set(value):
		if value <= amount_of_tasks:
			completed_tasks = value
		else:
			completed_tasks = amount_of_tasks

var is_shift_timer_active = true
var is_tasks_active = true
var is_breathing_active = true
var is_ripper_active = true
var is_valve_active = true
var is_hypno_active = true
var is_bleach_active = true
var is_rage_mode_active = false 

var rage_triggered_by_valve = false
var rage_timer = 0.0

func _process(delta):
	if rage_triggered_by_valve and rage_timer > 0:
		rage_timer -= delta
		if rage_timer <= 0:
			is_rage_mode_active = false
			rage_triggered_by_valve = false

	var block_timer = rage_triggered_by_valve and rage_timer > 20.0
	if is_shift_timer_active and shift_timer > 0 and not block_timer:
		shift_timer -= delta
		if shift_timer <= 0:
			shift_timer = 0

var last_death_reason: String = ""

func set_difficulty(level: int) -> void:
	difficulty = level
	completed_tasks = 0
	match level:
		1:
			amount_of_tasks = 3
			shift_timer = 120.0
		2:
			amount_of_tasks = 4
			shift_timer = 180.0
		3:
			amount_of_tasks = 6
			shift_timer = 240.0

#Game settings
var window_mode: int = 0:
	set(value):
		window_mode = value
		DisplayServer.window_set_mode(value)
		_save_config()

var vsync_enabled: bool = true:
	set(value):
		vsync_enabled = value
		if value:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		else:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		_save_config()

var resolutions: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440)
]

var resolution_index: int = 0:
	set(value):
		resolution_index = value
		if value >= 0 and value < resolutions.size():
			DisplayServer.window_set_size(resolutions[value])
		_save_config()

var mouse_sensitivity: float = 1.0:
	set(value):
		mouse_sensitivity = value
		_save_config()

var hear_loss_mode: bool = false:
	set(value):
		hear_loss_mode = value
		_save_config()

var _is_loading_config: bool = false

func _ready() -> void:
	_is_loading_config = true
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		window_mode = config.get_value("video", "window_mode", DisplayServer.window_get_mode())
		vsync_enabled = config.get_value("video", "vsync_enabled", true)
		resolution_index = config.get_value("video", "resolution_index", 0)
		mouse_sensitivity = config.get_value("game", "mouse_sensitivity", 1.0)
		hear_loss_mode = config.get_value("game", "hear_loss_mode", false)
	else:
		window_mode = DisplayServer.window_get_mode()
		var vsync_mode = DisplayServer.window_get_vsync_mode()
		vsync_enabled = (vsync_mode != DisplayServer.VSYNC_DISABLED)
		var current_size = DisplayServer.window_get_size()
		resolution_index = 0
		for i in range(resolutions.size()):
			if resolutions[i] == current_size:
				resolution_index = i
				break
		mouse_sensitivity = 1.0
		hear_loss_mode = false
	_is_loading_config = false

func _save_config() -> void:
	if _is_loading_config:
		return
	var config = ConfigFile.new()
	config.load("user://settings.cfg")
	config.set_value("video", "window_mode", window_mode)
	config.set_value("video", "vsync_enabled", vsync_enabled)
	config.set_value("video", "resolution_index", resolution_index)
	config.set_value("game", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("game", "hear_loss_mode", hear_loss_mode)
	config.save("user://settings.cfg")
