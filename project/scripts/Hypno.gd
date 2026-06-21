extends Node3D

# Настройки позиций и скорости
@export var START_POS: Vector3
@export var ATTACK_POS: Vector3
@export var MOVE_SPEED: float = 10.0
@export var HYPNO_SPEED: float = 0.5

# Новые настройки углов обзора для Инспектора
@export_group("Настройки Взгляда (Атаки)")
## Максимальный угол по горизонтали (влево/вправо от центра экрана) при котором работает атака
@export_range(0.0, 180.0, 0.5) var MAX_HORIZONTAL_ANGLE: float = 75.0
## Максимальный угол по вертикали (вверх/вниз от центра экрана) при котором работает атака
@export_range(0.0, 90.0, 0.5) var MAX_VERTICAL_ANGLE: float = 35.0
## Смещение точки фиксации взгляда по высоте от земли (чтобы целиться Гипно в лицо/грудь, а не в ноги)
@export var TARGET_HEIGHT_OFFSET: float = 1.6

var chance = 0.3
var hypno_position = "far"
var timer = 25.0
var kill_timer = 0.0
var is_at_target = false
var is_cooldown = false

@onready var shift_settings = get_node("/root/ShiftSettings")
@onready var player = get_node("../Player")
@onready var hypno_indicator = get_node("../HUD/HypnoNear")
@onready var death_hypno = get_node("../HUD/Death_hypno")
@onready var anim_player = $Hypno2/AnimationPlayer

func _ready() -> void:
	global_position = START_POS
	hide()

func _process(delta: float) -> void:
	if not player.alive: return

	if shift_settings.is_hypno_active:
		var is_rage = shift_settings.is_rage_mode_active if shift_settings else false
		
		if is_rage and not is_cooldown and hypno_position != "nearest" and timer > 1.0:
			timer = 1.0

		if timer > 0:
			timer -= delta
		if timer <= 0:
			is_cooldown = false
			
		_logic_cycle(delta)
	else:
		_reset_hypno()
	
	_update_visuals(delta)

func _logic_cycle(delta: float):
	var is_rage = shift_settings.is_rage_mode_active if shift_settings else false
	var current_chance = 1.0 if is_rage else chance
	var step_timer = 1.0 if is_rage else 25.0

	match hypno_position:
		"far":
			_process_movement(START_POS, delta, "Hypno_moving")
			if timer <= 0 and randf() < current_chance:
				hypno_position = "middle"
				timer = step_timer
		"middle":
			_process_movement(START_POS, delta, "Hypno_moving")
			if timer <= 0 and randf() < current_chance:
				hypno_position = "nearest"
				timer = 10.0
				is_at_target = false
				show()
		"nearest":
			if not is_at_target:
				_process_movement(ATTACK_POS, delta, "Hypno_moving")
				if global_position.distance_to(ATTACK_POS) < 0.2:
					is_at_target = true
			else:
				_rotate_to_target(player.global_position)
				_process_movement(ATTACK_POS, delta, "Hypno_kill")
				_attack_logic(delta)
			
			if timer <= 0:
				hypno_position = "far"
				timer = 30.0 / 1.5 if is_rage else 30.0
				is_cooldown = true
				is_at_target = false
				kill_timer = 0.0 

func _attack_logic(delta: float):
	var cam = player.find_child("Camera3D", true, false)
	if not cam:
		cam = player.find_child("Camera", true, false)
		
	var is_looking = false
	
	if cam:
		var target_point = global_position + Vector3(0, TARGET_HEIGHT_OFFSET, 0)
		var dir_to_hypno = (target_point - cam.global_position).normalized()
		var local_dir = cam.global_transform.basis.inverse() * dir_to_hypno
		
		if local_dir.z < 0:
			var angle_hor = abs(rad_to_deg(atan2(local_dir.x, -local_dir.z)))
			var angle_ver = abs(rad_to_deg(asin(local_dir.y)))
			
			if angle_hor < MAX_HORIZONTAL_ANGLE and angle_ver < MAX_VERTICAL_ANGLE:
				is_looking = true
	else:
		var target_point = global_position + Vector3(0, TARGET_HEIGHT_OFFSET, 0)
		var dir_to_hypno = (target_point - player.global_position).normalized()
		var forward = -player.global_transform.basis.z
		is_looking = forward.dot(dir_to_hypno) > 0.5
		
	var is_monitoring = player.is_monitoring if "is_monitoring" in player else false
	
	if is_looking or is_monitoring:
		kill_timer = clamp(kill_timer + (HYPNO_SPEED * delta), 0.0, 1.0)
		if kill_timer >= 1.0:
			player._die("HYPNO", self)
	else:
		kill_timer = clamp(kill_timer - (HYPNO_SPEED * delta), 0.0, 1.0)

func _process_movement(target: Vector3, delta: float, anim_name: String):
	if anim_player.has_animation(anim_name) and anim_player.current_animation != anim_name:
		anim_player.play(anim_name)

	if global_position.distance_to(target) > 0.1:
		_rotate_to_target(target)
		var direction = (target - global_position).normalized()
		global_position += direction * MOVE_SPEED * delta
	elif hypno_position == "far":
		hide()

func _rotate_to_target(target_pos: Vector3):
	var look_target = target_pos
	look_target.y = global_position.y
	
	if global_position.distance_to(look_target) > 0.01:
		look_at(look_target, Vector3.UP)
		rotate_object_local(Vector3.UP, deg_to_rad(90))

func _update_visuals(delta: float):
	if hypno_indicator:
		if shift_settings and "hear_loss_mode" in shift_settings and shift_settings.hear_loss_mode and hypno_position == "nearest":
			hypno_indicator.show()
			hypno_indicator.modulate.a = 1.0
		else:
			hypno_indicator.hide()
	
	if death_hypno:
		death_hypno.color.a = lerp(death_hypno.color.a, kill_timer, delta * 4.0)

func _reset_hypno():
	hypno_position = "far"
	kill_timer = 0.0
	is_at_target = false
	is_cooldown = false
	if death_hypno:
		death_hypno.color.a = 0.0
	global_position = START_POS
	hide()
