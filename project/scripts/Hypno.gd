extends Node3D

@export var START_POS: Vector3
@export var ATTACK_POS: Vector3
@export var MOVE_SPEED: float = 10.0
@export var HYPNO_SPEED: float = 0.5

var chance = 0.3
var hypno_position = "far"
var timer = 1.0
var kill_timer = 0.0
var is_at_target = false

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
		if timer > 0:
			timer -= delta
		_logic_cycle(delta)
	else:
		_reset_hypno()
	
	_update_visuals(delta)

func _logic_cycle(delta: float):
	match hypno_position:
		"far":
			_process_movement(START_POS, delta, "Hypno_moving")
			if randf() < chance and timer <= 0:
				hypno_position = "middle"
				timer = 1.0
		"middle":
			_process_movement(START_POS, delta, "Hypno_moving")
			if randf() < chance and timer <= 0:
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
				timer = 30.0
				is_at_target = false
				kill_timer = 0.0 

func _attack_logic(delta: float):
	if player.horizontal_view == "center" and player.vertical_view == "center" and !player.is_monitoring:
		kill_timer = clamp(kill_timer + (HYPNO_SPEED * delta), 0.0, 1.0)
		if kill_timer >= 1.0:
			player._die("HYPNO")
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
		if hypno_position == "nearest":
			hypno_indicator.show()
		else:
			hypno_indicator.hide()
	
	if death_hypno:
		death_hypno.color.a = lerp(death_hypno.color.a, kill_timer, delta * 4.0)

func _reset_hypno():
	hypno_position = "far"
	kill_timer = 0.0
	is_at_target = false
	if death_hypno:
		death_hypno.color.a = 0.0
	global_position = START_POS
	hide()
