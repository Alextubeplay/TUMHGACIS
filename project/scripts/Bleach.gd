extends Node3D

@export var START_POS: Vector3
@export var MOVE_SPEED: float = 12.5
@export var KILL_DISTANCE: float = 3.0 
@export var FLOOR_Y: float = 0.0

var chance = 0.8
var bleach_position = "far"
var timer = 25.0
var is_processing_closure = false

@onready var shift_settings = get_node("/root/ShiftSettings")
@onready var crematory = $"../Crematory"
@onready var player = $"../Player"
@onready var bleach_indicator = $"../HUD/BleachNear"
@onready var anim_player = $Bleach2/AnimationPlayer

func _ready() -> void:
	global_position = START_POS
	hide()

func _process(delta: float) -> void:
	if not player.alive: return
	if not shift_settings.is_bleach_active: return
	if not crematory.is_opened:
		if not is_processing_closure:
			is_processing_closure = true
			_check_door_consequence()
		return 
	else:
		is_processing_closure = false
	
	if timer > 0:
		timer -= delta
	_logic()

func _check_door_consequence():
	if bleach_position == "near" or bleach_position == "nearest":
		bleach_position = "far"
		timer = 25.0
		hide()
	elif bleach_position == "far" or bleach_position == "middle":
		if player.alive:
			_mob_kicks_door()
	if bleach_indicator: bleach_indicator.hide()

func _mob_kicks_door():
	await get_tree().create_timer(1.0).timeout
	if not crematory.is_opened:
		crematory.kick_at_player(player.global_position)
		await get_tree().create_timer(0.1).timeout
		show()
		global_position = START_POS
		if anim_player.has_animation("Bleach_jump"):
			anim_player.play("Bleach_jump")
		player._die("BLEACH", self)

func _logic():
	match bleach_position:
		"far":
			if randf() < chance and timer <= 0:
				bleach_position = "middle"
				timer = 25.0
		"middle":
			if randf() < (chance * 0.5) and timer <= 0:
				bleach_position = "near"
				timer = 25.0
		"near":
			if randf() < (chance * 0.25) and timer <= 0:
				bleach_position = "nearest"
				timer = 20.0
		"nearest":
			if bleach_indicator: bleach_indicator.show()
			if timer <= 10.0 and player.alive:
				player._die("BLEACH", self)
				timer = 30.0

func start_kill_sequence_movement():
	show()
	
	if anim_player.has_animation("Bleach_jump"):
		anim_player.play("Bleach_jump")
		await anim_player.animation_finished
	
	global_position.y = FLOOR_Y

	if anim_player.has_animation("Bleach_moving"):
		var anim = anim_player.get_animation("Bleach_moving")
		anim.loop_mode = Animation.LOOP_LINEAR
		anim_player.play("Bleach_moving")
		
		while true:
			var target_pos = player.global_position
			target_pos.y = FLOOR_Y
			
			var dist = global_position.distance_to(target_pos)
			
			if dist <= KILL_DISTANCE:
				return
				
			var direction = (target_pos - global_position).normalized()
			global_position += direction * MOVE_SPEED * get_process_delta_time()
			
			look_at(target_pos, Vector3.UP)
			rotate_object_local(Vector3.UP, deg_to_rad(90))
			
			await get_tree().process_frame

func play_kill_animation():
	if anim_player.has_animation("Bleach_kill"):
		anim_player.play("Bleach_kill")
