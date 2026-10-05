extends Node
## Autoload: Database
## Файл: res://scripts/Database.gd

const USER_PATH := "user://game.db"
const SCHEMA_VERSION := 5

var db: SQLite


func _ready() -> void:
	db = SQLite.new()
	db.path = USER_PATH
	db.foreign_keys = true
	if not db.open_db():
		push_error("Не открылась БД: " + str(db.error_message))
		return
	_ensure_schema()
	


func _ensure_schema() -> void:
	db.query("SELECT name FROM sqlite_master WHERE type='table' AND name='meta';")
	var need_create := db.query_result.is_empty()
	if not need_create:
		db.query("SELECT version FROM meta WHERE id = 1;")
		if db.query_result.is_empty() or int(db.query_result[0]["version"]) != SCHEMA_VERSION:
			need_create = true
	if not need_create:
		return
	db.close_db()
	var abs_path := ProjectSettings.globalize_path(USER_PATH)
	if FileAccess.file_exists(USER_PATH):
		DirAccess.remove_absolute(abs_path)
	db.path = USER_PATH
	db.foreign_keys = true
	if not db.open_db():
		push_error("Не открылась БД после сброса: " + str(db.error_message))
		return
	print("Создаю таблицы (версия %d)..." % SCHEMA_VERSION)
	for statement in _split_sql(_SCHEMA):
		if not db.query(statement):
			push_error("SQL ошибка: " + str(db.error_message))
			push_error(statement)
			return
	print("Таблицы созданы")


func _split_sql(sql: String) -> PackedStringArray:
	var out: PackedStringArray = []
	var current := ""
	for line in sql.split("\n"):
		var trimmed := line.strip_edges()
		if trimmed.begins_with("--"):
			continue
		current += " " + line
		if trimmed.ends_with(";"):
			var stmt := current.strip_edges()
			if stmt != ";" and stmt != "":
				out.append(stmt)
			current = ""
	return out


func query(sql: String) -> Array:
	if db == null:
		return []
	if not db.query(sql):
		push_error("SQL ошибка: " + str(db.error_message) + " | " + sql)
		return []
	return db.query_result


func get_difficulty(difficulty_id: int) -> Dictionary:
	var rows := query("SELECT * FROM difficulties WHERE id = %d;" % difficulty_id)
	return {} if rows.is_empty() else rows[0]


func get_all_mobs() -> Array:
	return query("SELECT * FROM mobs ORDER BY id;")

func get_mob_by_name(mob_name: String) -> Dictionary:
	var safe := mob_name.replace("'", "''")
	var rows := query("SELECT * FROM mobs WHERE name = '%s';" % safe)
	return {} if rows.is_empty() else rows[0]


func get_mob_activations(mob_id: int, difficulty_id: int):
	var rows := query("""
		SELECT activations FROM mob_parameters
		WHERE mob_id = %d AND difficulty_id = %d;
	""" % [mob_id, difficulty_id])
	if rows.is_empty():
		return null
	return rows[0]["activations"]


func pick_mobs_for_shift(difficulty_id: int) -> Array:
	var diff := get_difficulty(difficulty_id)
	if diff.is_empty():
		return []
	var need := int(diff["mob_count"])
	var pool: Array = get_all_mobs()
	if pool.is_empty() or need <= 0:
		return []
	var result: Array = []
	var deck: Array = []
	while result.size() < need:
		if deck.is_empty():
			deck = pool.duplicate()
			deck.shuffle()
		result.append(deck.pop_back())
	return result


func get_tasks() -> Array:
	return query("SELECT id, name, scene_path FROM tasks;")


func get_death_reason(code: String) -> Dictionary:
	var safe := code.replace("'", "''")
	var rows := query("""
		SELECT dr.id, dr.code, dr.mob_id, m.name AS mob_name
		FROM death_reasons dr
		LEFT JOIN mobs m ON m.id = dr.mob_id
		WHERE dr.code = '%s';
	""" % safe)
	return {} if rows.is_empty() else rows[0]


func record_death(code: String) -> Dictionary:
	var reason := get_death_reason(code.to_upper())
	if reason.is_empty():
		push_error("Нет такой причины смерти в базе: " + code)
		return {}
	query("UPDATE statistics SET losses = losses + 1 WHERE id = 1;")
	var reason_code := str(reason.get("code", "")).to_upper()
	var mob_id = reason.get("mob_id")
	if reason_code == "DOOR" and mob_id != null:
		query("UPDATE statistics_mobs SET door_losses = door_losses + 1 WHERE mob_id = %d;" % int(mob_id))
	elif mob_id == null:
		query("UPDATE statistics SET asphyxiation_losses = asphyxiation_losses + 1 WHERE id = 1;")
	else:
		query("UPDATE statistics_mobs SET losses = losses + 1 WHERE mob_id = %d;" % int(mob_id))
	return reason

func get_settings() -> Dictionary:
	var rows := query("SELECT * FROM settings WHERE id = 1;")
	return {} if rows.is_empty() else rows[0]

func set_selected_difficulty(difficulty_id: int) -> void:
	query("UPDATE settings SET difficulty_id = %d WHERE id = 1;" % difficulty_id)


func get_selected_difficulty() -> int:
	var s := get_settings()
	if s.is_empty():
		return 1
	return int(s.get("difficulty_id", 1))

func save_settings(data: Dictionary) -> void:
	query("""
		UPDATE settings SET
			difficulty_id = %d,
			window_mode = %d,
			resolution_index = %d,
			vsync = %d,
			master_volume = %s,
			music_volume = %s,
			sounds_volume = %s,
			mouse_sensitivity = %s,
			hear_loss_mode = %d,
			endless_mode = %d,
			language_index = %d
		WHERE id = 1;
	""" % [
		int(data.get("difficulty_id", 1)),
		int(data.get("window_mode", 0)),
		int(data.get("resolution_index", 0)),
		int(data.get("vsync", 1)),
		str(float(data.get("master_volume", 50.0))),
		str(float(data.get("music_volume", 30.0))),
		str(float(data.get("sounds_volume", 30.0))),
		str(float(data.get("mouse_sensitivity", 50.0))),
		int(data.get("hear_loss_mode", 0)),
		int(data.get("endless_mode", 0)),
		int(data.get("language_index", 0)),
	]);

func get_statistics() -> Dictionary:
	var rows := query("SELECT * FROM statistics WHERE id = 1;")
	return {} if rows.is_empty() else rows[0]


func get_statistics_tasks() -> Array:
	return query("""
		SELECT st.task_id, t.name, st.completed, st.errors
		FROM statistics_tasks st
		JOIN tasks t ON t.id = st.task_id
		ORDER BY st.task_id;
	""")


func get_statistics_mobs() -> Array:
	return query("""
		SELECT sm.mob_id, m.name, sm.losses, sm.fight_off, sm.door_losses
		FROM statistics_mobs sm
		JOIN mobs m ON m.id = sm.mob_id
		ORDER BY sm.mob_id;
	""")


const _SCHEMA := """
CREATE TABLE meta (
    id INTEGER PRIMARY KEY,
    version INTEGER NOT NULL
);

CREATE TABLE difficulties (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    task_count INTEGER NOT NULL,
    shift_timer_sec REAL NOT NULL,
    mob_count INTEGER NOT NULL
);

CREATE TABLE mobs (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    chance REAL NOT NULL,
    step_timer REAL NOT NULL,
    kill_timer REAL NOT NULL
);

CREATE TABLE mob_parameters (
    mob_id INTEGER NOT NULL,
    difficulty_id INTEGER NOT NULL,
    activations INTEGER,
    PRIMARY KEY (mob_id, difficulty_id),
    FOREIGN KEY (mob_id) REFERENCES mobs(id),
    FOREIGN KEY (difficulty_id) REFERENCES difficulties(id)
);

CREATE TABLE models (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    file_path TEXT NOT NULL
);

CREATE TABLE textures (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    file_path TEXT NOT NULL
);

CREATE TABLE model_texture (
    model_id INTEGER NOT NULL,
    texture_id INTEGER NOT NULL,
    PRIMARY KEY (model_id, texture_id),
    FOREIGN KEY (model_id) REFERENCES models(id),
    FOREIGN KEY (texture_id) REFERENCES textures(id)
);

CREATE TABLE mob_model (
    mob_id INTEGER NOT NULL,
    model_id INTEGER NOT NULL,
    animation_type TEXT NOT NULL,
    PRIMARY KEY (mob_id, model_id, animation_type),
    FOREIGN KEY (mob_id) REFERENCES mobs(id),
    FOREIGN KEY (model_id) REFERENCES models(id)
);

CREATE TABLE tasks (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    scene_path TEXT NOT NULL UNIQUE
);

CREATE TABLE settings (
    id INTEGER PRIMARY KEY,
    difficulty_id INTEGER NOT NULL,
    window_mode INTEGER NOT NULL DEFAULT 0,
    resolution_index INTEGER NOT NULL DEFAULT 0,
    vsync INTEGER NOT NULL DEFAULT 1,
    master_volume REAL NOT NULL DEFAULT 50.0,
    music_volume REAL NOT NULL DEFAULT 30.0,
    sounds_volume REAL NOT NULL DEFAULT 30.0,
    mouse_sensitivity REAL NOT NULL DEFAULT 50.0,
    hear_loss_mode INTEGER NOT NULL DEFAULT 0,
    endless_mode INTEGER NOT NULL DEFAULT 0,
    language_index INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (difficulty_id) REFERENCES difficulties(id)
);

CREATE TABLE sounds (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    file_path TEXT NOT NULL,
    group_name TEXT NOT NULL
);

CREATE TABLE death_reasons (
    id INTEGER PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    mob_id INTEGER,
    FOREIGN KEY (mob_id) REFERENCES mobs(id)
);

INSERT INTO meta (id, version) VALUES (1, 5);

INSERT INTO difficulties (id, name, task_count, shift_timer_sec, mob_count) VALUES
    (1, 'Easy', 3, 120.0, 2),
    (2, 'Normal', 5, 180.0, 3),
    (3, 'Hard', 7, 240.0, 4);

INSERT INTO mobs (id, name, chance, step_timer, kill_timer) VALUES
    (1, 'Bleach', 0.80, 30.0, 20.0),
    (2, 'Hypno', 0.30, 25.0, 10.0),
    (3, 'Ripper', 0.30, 30.0, 20.0),
    (4, 'Bloody', 0.0047, 30.0, 10.0);

INSERT INTO mob_parameters (mob_id, difficulty_id, activations) VALUES
    (1, 1, NULL),
    (1, 2, NULL),
    (1, 3, NULL),
    (2, 1, NULL),
    (2, 2, NULL),
    (2, 3, NULL),
    (3, 1, NULL),
    (3, 2, NULL),
    (3, 3, NULL),
    (4, 1, 2),
    (4, 2, 4),
    (4, 3, 100);

INSERT INTO models (id, name, file_path) VALUES
    (1, 'Bleach2', 'res://models/Bleach2.tscn'),
    (2, 'Hypno2', 'res://models/Hypno2.tscn'),
    (3, 'Ripper2', 'res://models/Ripper2.tscn'),
    (4, 'Bloody2', 'res://models/Bloody2.tscn'),
    (5, 'Valve', 'res://models/Valve.tscn'),
    (6, 'Crematory', 'res://models/Crematory.tscn'),
    (7, 'Ventilation', 'res://models/Ventilation.tscn');

INSERT INTO textures (id, name, file_path) VALUES
    (1, 'bleach_albedo', 'res://models/materials/bleach_albedo.png'),
    (2, 'hypno_albedo', 'res://models/materials/hypno_albedo.png'),
    (3, 'ripper_albedo', 'res://models/materials/ripper_albedo.png'),
    (4, 'bloody_albedo', 'res://models/materials/bloody_albedo.png');

INSERT INTO model_texture (model_id, texture_id) VALUES
    (1, 1), (2, 2), (3, 3), (4, 4);

INSERT INTO mob_model (mob_id, model_id, animation_type) VALUES
    (1, 1, 'jump'),
    (1, 1, 'moving'),
    (1, 1, 'kill'),
    (2, 2, 'moving'),
    (2, 2, 'kill'),
    (3, 3, 'moving'),
    (3, 3, 'kill'),
    (4, 4, 'moving'),
    (4, 4, 'kill');

INSERT INTO tasks (id, name, scene_path) VALUES
    (1, 'Clicker', 'res://scenes/Clicker.tscn'),
    (2, 'Colorful_wires', 'res://scenes/Colorful_wires.tscn'),
    (3, 'Colorless_wires', 'res://scenes/Colorless_wires.tscn'),
    (4, 'Maze', 'res://scenes/Maze.tscn');

INSERT INTO settings (
    id, difficulty_id, window_mode, resolution_index, vsync,
    master_volume, music_volume, sounds_volume,
    mouse_sensitivity, hear_loss_mode, endless_mode, language_index
) VALUES (1, 1, 0, 0, 1, 50.0, 30.0, 30.0, 50.0, 0, 0, 0);

INSERT INTO sounds (name, file_path, group_name) VALUES
    ('screamer', 'res://audio/screamer.ogg', 'UI'),
    ('rage_mode_music', 'res://audio/rage_mode_music.ogg', 'Ambient'),
    ('bleach_attack', 'res://audio/bleach_attack.ogg', 'Bleach'),
    ('bleach_door_break', 'res://audio/bleach_door_break.ogg', 'Bleach'),
    ('bleach_door_open', 'res://audio/bleach_door_open.ogg', 'Bleach'),
    ('bleach_nearby', 'res://audio/bleach_nearby.ogg', 'Bleach'),
    ('ripper_attack', 'res://audio/ripper_attack.ogg', 'Ripper'),
    ('ripper_nearby', 'res://audio/ripper_nearby.ogg', 'Ripper'),
    ('ripper_left', 'res://audio/ripper_left.ogg', 'Ripper'),
    ('hypno_attack', 'res://audio/hypno_attack.ogg', 'Hypno'),
    ('hypno_footsteps', 'res://audio/hypno_footsteps.ogg', 'Hypno'),
    ('hypno_hypnosis', 'res://audio/hypno_hypnosis.ogg', 'Hypno'),
    ('bloody_attack', 'res://audio/bloody_attack.ogg', 'Bloody'),
    ('bloody_valve_rip', 'res://audio/bloody_valve_rip.ogg', 'Bloody'),
    ('bloody_valve_hit', 'res://audio/bloody_valve_hit.ogg', 'Bloody'),
    ('bloody_valve_tighten', 'res://audio/bloody_valve_tighten.ogg', 'Bloody'),
    ('monitor_on', 'res://audio/monitor_on.ogg', 'UI'),
    ('monitor_off', 'res://audio/monitor_off.ogg', 'UI');

INSERT INTO death_reasons (code, mob_id) VALUES
    ('BLEACH', 1),
    ('HYPNO', 2),
    ('RIPPER', 3),
    ('BLOODY', 4),
    ('DOOR', 1),
    ('ASPHYXATION', NULL);

CREATE TABLE statistics (
    id INTEGER PRIMARY KEY,
    games_played INTEGER NOT NULL DEFAULT 0,
    wins INTEGER NOT NULL DEFAULT 0,
    losses INTEGER NOT NULL DEFAULT 0,
    total_time_in_game REAL NOT NULL DEFAULT 0,
    total_tasks_completed INTEGER NOT NULL DEFAULT 0,
    asphyxiation_losses INTEGER NOT NULL DEFAULT 0,
    favourite_task_id INTEGER,
    most_hated_mob_id INTEGER,
    FOREIGN KEY (favourite_task_id) REFERENCES tasks(id),
    FOREIGN KEY (most_hated_mob_id) REFERENCES mobs(id)
);

CREATE TABLE statistics_tasks (
    task_id INTEGER PRIMARY KEY,
    completed INTEGER NOT NULL DEFAULT 0,
    errors INTEGER,
    FOREIGN KEY (task_id) REFERENCES tasks(id)
);

CREATE TABLE statistics_mobs (
    mob_id INTEGER PRIMARY KEY,
    losses INTEGER NOT NULL DEFAULT 0,
    fight_off INTEGER NOT NULL DEFAULT 0,
    door_losses INTEGER,
    FOREIGN KEY (mob_id) REFERENCES mobs(id)
);

INSERT INTO statistics (
    id, games_played, wins, losses, total_time_in_game,
    total_tasks_completed, asphyxiation_losses,
    favourite_task_id, most_hated_mob_id
) VALUES (1, 0, 0, 0, 0, 0, 0, NULL, NULL);

INSERT INTO statistics_tasks (task_id, completed, errors) VALUES
    (1, 0, 0),
    (2, 0, NULL),
    (3, 0, NULL),
    (4, 0, 0);

INSERT INTO statistics_mobs (mob_id, losses, fight_off, door_losses) VALUES
    (1, 0, 0, 0),
    (2, 0, 0, NULL),
    (3, 0, 0, NULL),
    (4, 0, 0, NULL);
"""
