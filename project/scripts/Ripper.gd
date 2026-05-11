extends Node3D

@export var KILL_DISTANCE: float = 2.7 
@export var MOVE_SPEED: float = 12.5

var chance = 0.3
var ripper_position = "far"
var timer = 25.0

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
		if timer > 0:
			timer -= delta
		else:
			timer = 25.0
		_moving()
	else:
		ripper_position = "far"
		hide()
	
	if ripper_position == "nearest":
		ripper_indicator.show()
	else:
		ripper_indicator.hide()

func _moving():
	match ripper_position:
		"far":
			if randf() < chance and timer <= 0:
				ripper_position = "middle"
				timer = 25.0
		"middle":
			if randf() < (chance * 2) and timer <= 0:
				ripper_position = "near"
				timer = 25.0
		"near":
			if randf() < (chance * 2.5) and timer <= 0:
				ripper_position = "nearest"
				timer = 30.0
		"nearest":
			if timer <= 20 and player.alive:
				player._die("RIPPER", self)
				timer = 30.0

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
