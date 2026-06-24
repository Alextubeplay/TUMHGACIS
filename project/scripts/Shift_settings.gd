extends Node

const DEFAULT_WINDOW_MODE = DisplayServer.WINDOW_MODE_WINDOWED
const DEFAULT_RESOLUTION_INDEX = 0
const DEFAULT_VSYNC_ENABLED = true
const DEFAULT_MASTER_VOLUME = 50.0
const DEFAULT_MUSIC_VOLUME = 30.0
const DEFAULT_SOUNDS_VOLUME = 30.0
const DEFAULT_MOUSE_SENSITIVITY = 50.0
const DEFAULT_HEAR_LOSS_MODE = false
const DEFAULT_ENDLESS_MODE = false

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
	_save_config()

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
	Vector2i(640, 480),
	Vector2i(800, 600),
	Vector2i(1024, 768),
	Vector2i(1280, 1024),
	Vector2i(1680, 1050),
	Vector2i(1920, 1080),
	Vector2i(2560, 2160)
]

var resolution_index: int = 0:
	set(value):
		resolution_index = value
		if value >= 0 and value < resolutions.size():
			DisplayServer.window_set_size(resolutions[value])
		_save_config()

var mouse_sensitivity: float = 50.0:
	set(value):
		mouse_sensitivity = value
		_save_config()

var hear_loss_mode: bool = false:
	set(value):
		hear_loss_mode = value
		_save_config()

var endless_mode: bool = false:
	set(value):
		endless_mode = value
		_save_config()

var master_volume: float = 50.0:
	set(value):
		master_volume = value
		_apply_volume("Master", value)
		_save_config()

var music_volume: float = 50.0:
	set(value):
		music_volume = value
		_apply_volume("Music", value)
		_save_config()

var sounds_volume: float = 50.0:
	set(value):
		sounds_volume = value
		_apply_volume("Sounds", value)
		_save_config()

var _is_loading_config: bool = false

func _ready() -> void:
	_is_loading_config = true
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		window_mode = config.get_value("video", "window_mode", DisplayServer.window_get_mode())
		vsync_enabled = config.get_value("video", "vsync_enabled", true)
		resolution_index = config.get_value("video", "resolution_index", 0)
		mouse_sensitivity = config.get_value("game", "mouse_sensitivity", 50.0)
		hear_loss_mode = config.get_value("game", "hear_loss_mode", false)
		endless_mode = config.get_value("game", "endless_mode", false)
		master_volume = config.get_value("audio", "master_volume", 50.0)
		music_volume = config.get_value("audio", "music_volume", 50.0)
		sounds_volume = config.get_value("audio", "sounds_volume", 50.0)
		var saved_diff = config.get_value("game", "difficulty", 1)
		set_difficulty(saved_diff)
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
		mouse_sensitivity = 50.0
		hear_loss_mode = false
		endless_mode = false
		master_volume = 50.0
		music_volume = 50.0
		sounds_volume = 50.0
		set_difficulty(1)
	_is_loading_config = false

func _apply_volume(bus_name: String, value: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(value / 50.0))
		AudioServer.set_bus_mute(bus_index, value <= 0.0)

func reset_graphics() -> void:
	window_mode = DEFAULT_WINDOW_MODE
	resolution_index = DEFAULT_RESOLUTION_INDEX
	vsync_enabled = DEFAULT_VSYNC_ENABLED

func reset_audio() -> void:
	master_volume = DEFAULT_MASTER_VOLUME
	music_volume = DEFAULT_MUSIC_VOLUME
	sounds_volume = DEFAULT_SOUNDS_VOLUME

func reset_gameplay() -> void:
	mouse_sensitivity = DEFAULT_MOUSE_SENSITIVITY
	hear_loss_mode = DEFAULT_HEAR_LOSS_MODE
	endless_mode = DEFAULT_ENDLESS_MODE

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
	config.set_value("game", "endless_mode", endless_mode)
	config.set_value("game", "difficulty", difficulty)
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sounds_volume", sounds_volume)
	config.save("user://settings.cfg")
