extends Node3D

@export var KILL_DISTANCE: float = 2.7 
@export var MOVE_SPEED: float = 12.5

var chance = 0.3
var ripper_position = "far"
var timer = 20.0
var is_cooldown = false
var retreat_timer = 0.0

@onready var shift_settings = get_node("/root/ShiftSettings")
@onready var vent = get_node("../Ventilation")
@onready var player = get_node("../Player")
@onready var ripper_indicator = get_node("../HUD/RipperNear")
@onready var anim_player = $Ripper2/AnimationPlayer

func _ready() -> void:
	randomize()
	hide()

func _process(delta: float) -> void:
	if not player.alive:
		return

	if vent.is_opened and shift_settings.is_ripper_active:
		retreat_timer = 0.0
		var is_rage = shift_settings.is_rage_mode_active if shift_settings else false
		if is_rage and not is_cooldown and ripper_position != "nearest" and timer > 1.0:
			timer = 1.0

		if timer > 0:
			timer -= delta
		if timer <= 0:
			is_cooldown = false
			
		_moving()
	else:
		if ripper_position != "far":
			if retreat_timer == 0.0:
				retreat_timer = randf_range(5.0, 8.0)
			
			retreat_timer -= delta
			if retreat_timer <= 0.0:
				ripper_position = "far"
				var is_rage = shift_settings.is_rage_mode_active if shift_settings else false
				timer = 10.0 / 1.5 if is_rage else 10.0
				is_cooldown = true
				retreat_timer = 0.0
		hide()
	
	if shift_settings and "hear_loss_mode" in shift_settings and shift_settings.hear_loss_mode:
		if ripper_position == "nearest":
			ripper_indicator.show()
			ripper_indicator.modulate.a = 1.0
		else:
			ripper_indicator.hide()
	else:
		ripper_indicator.hide()

func _moving():
	var is_rage = shift_settings.is_rage_mode_active if shift_settings else false
	var step_timer = 1.0 if is_rage else 30.0

	match ripper_position:
		"far":
			if timer <= 0 and (is_rage or (randf() < chance)):
				ripper_position = "middle"
				timer = step_timer
		"middle":
			if timer <= 0 and (is_rage or (randf() < chance * 2)):
				ripper_position = "near"
				timer = step_timer
		"near":
			if timer <= 0 and (is_rage or (randf() < chance * 2.5)):
				ripper_position = "nearest"
				timer = 30.0
		"nearest":
			if timer <= 20 and player.alive:
				player._die("RIPPER", self)
				timer = 20.0

func start_kill_sequence_movement():
	show()
	if anim_player.has_animation("Ripper_moving"):
		var anim = anim_player.get_animation("Ripper_moving")
		anim.loop_mode = Animation.LOOP_LINEAR
		anim_player.play("Ripper_moving")
		
		while true:
			var target_pos = player.global_position
			target_pos.y = global_position.y
			var dist = global_position.distance_to(target_pos)
			if dist <= KILL_DISTANCE:
				break
			var direction = (target_pos - global_position).normalized()
			global_position += direction * MOVE_SPEED * get_process_delta_time()
			look_at(target_pos, Vector3.UP)
			rotate_object_local(Vector3.UP, deg_to_rad(90))
			await get_tree().process_frame

func play_kill_animation():
	if anim_player.has_animation("Ripper_kill"):
		anim_player.play("Ripper_kill")
