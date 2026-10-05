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
const DEFAULT_LANGUAGE_INDEX = 0

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

var selected_mobs: Array = []
var valve_activations = 2

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
	if Database.db != null:
		Database.set_selected_difficulty(level)
		_apply_difficulty_stats()
	_save_config()

func _apply_difficulty_stats() -> void:
	if Database.db == null:
		return
	var diff = Database.get_difficulty(difficulty)
	if diff.is_empty():
		push_error("Нет сложности с id=%d" % difficulty)
		return
	amount_of_tasks = int(diff["task_count"])
	shift_timer = float(diff["shift_timer_sec"])
	var acts = Database.get_mob_activations(4, difficulty)
	if acts != null:
		valve_activations = int(acts)

func prepare_shift() -> void:
	is_bleach_active = false
	is_hypno_active = false
	is_ripper_active = false
	is_valve_active = false
	selected_mobs.clear()

	if Database.db == null:
		push_error("База ещё не открыта")
		return

	_apply_difficulty_stats()

	var picked: Array = Database.pick_mobs_for_shift(difficulty)
	for row in picked:
		var n := str(row["name"])
		selected_mobs.append(n)
		match n:
			"Bleach":
				is_bleach_active = true
			"Hypno":
				is_hypno_active = true
			"Ripper":
				is_ripper_active = true
			"Bloody":
				is_valve_active = true

func _load_difficulty_from_db() -> void:
	_load_config()

var window_mode: int:
	set(value):
		window_mode = value
		DisplayServer.window_set_mode(value)
		_save_config()

var vsync_enabled: bool:
	set(value):
		vsync_enabled = value
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if value else DisplayServer.VSYNC_DISABLED)
		_save_config()

var resolutions = [Vector2i(1152, 648), Vector2i(1280, 720), Vector2i(1920, 1080)]
var resolution_index: int:
	set(value):
		resolution_index = value
		if window_mode == DisplayServer.WINDOW_MODE_WINDOWED and value < resolutions.size():
			DisplayServer.window_set_size(resolutions[value])
		_save_config()

var mouse_sensitivity: float:
	set(value):
		mouse_sensitivity = value
		_save_config()

var hear_loss_mode: bool:
	set(value):
		hear_loss_mode = value
		_save_config()

var endless_mode: bool:
	set(value):
		endless_mode = value
		_save_config()

var language_index: int:
	set(value):
		language_index = value
		if value == 0:
			TranslationServer.set_locale("en")
		elif value == 1:
			TranslationServer.set_locale("ru")
		_save_config()

var master_volume: float:
	set(value):
		master_volume = value
		_apply_volume("Master", value)
		_save_config()

var music_volume: float:
	set(value):
		music_volume = value
		_apply_volume("Music", value)
		_save_config()

var sounds_volume: float:
	set(value):
		sounds_volume = value
		_apply_volume("Sounds", value)
		_save_config()

var _is_loading_config = false

func _ready():
	call_deferred("_load_difficulty_from_db")

func _load_config():
	_is_loading_config = true

	var s: Dictionary = {}
	if Database.db != null:
		s = Database.get_settings()

	if s.is_empty():
		window_mode = DEFAULT_WINDOW_MODE
		vsync_enabled = DEFAULT_VSYNC_ENABLED
		resolution_index = DEFAULT_RESOLUTION_INDEX
		mouse_sensitivity = DEFAULT_MOUSE_SENSITIVITY
		hear_loss_mode = DEFAULT_HEAR_LOSS_MODE
		endless_mode = DEFAULT_ENDLESS_MODE
		language_index = DEFAULT_LANGUAGE_INDEX
		master_volume = DEFAULT_MASTER_VOLUME
		music_volume = DEFAULT_MUSIC_VOLUME
		sounds_volume = DEFAULT_SOUNDS_VOLUME
		difficulty = 1
	else:
		window_mode = int(s.get("window_mode", DEFAULT_WINDOW_MODE))
		vsync_enabled = bool(int(s.get("vsync", 1)))
		resolution_index = int(s.get("resolution_index", DEFAULT_RESOLUTION_INDEX))
		mouse_sensitivity = float(s.get("mouse_sensitivity", DEFAULT_MOUSE_SENSITIVITY))
		hear_loss_mode = bool(int(s.get("hear_loss_mode", 0)))
		endless_mode = bool(int(s.get("endless_mode", 0)))
		language_index = int(s.get("language_index", DEFAULT_LANGUAGE_INDEX))
		master_volume = float(s.get("master_volume", DEFAULT_MASTER_VOLUME))
		music_volume = float(s.get("music_volume", DEFAULT_MUSIC_VOLUME))
		sounds_volume = float(s.get("sounds_volume", DEFAULT_SOUNDS_VOLUME))
		difficulty = int(s.get("difficulty_id", 1))

	if Database.db != null:
		_apply_difficulty_stats()

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
	language_index = DEFAULT_LANGUAGE_INDEX

func _save_config() -> void:
	if _is_loading_config:
		return
	if Database.db == null:
		return
	Database.save_settings({
		"difficulty_id": difficulty,
		"window_mode": window_mode,
		"resolution_index": resolution_index,
		"vsync": 1 if vsync_enabled else 0,
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sounds_volume": sounds_volume,
		"mouse_sensitivity": mouse_sensitivity,
		"hear_loss_mode": 1 if hear_loss_mode else 0,
		"endless_mode": 1 if endless_mode else 0,
		"language_index": language_index,
	})
