extends Node3D

var alive = true
var start_position: Vector3
var horizontal_view = "center"
var vertical_view = "center"
var is_monitoring = false

@onready var shift_settings = get_node("/root/ShiftSettings")
@onready var oxygen_manager = $Oxygen_manager
@onready var valve = get_node("../Valve")
@onready var vent = get_node("../Ventilation")
@onready var crematory = get_node("../Crematory")
@onready var monitor = get_node("../Monitor")
@onready var death_blood = $"../HUD/Death_blood" 

func _ready():
	start_position = position
	if oxygen_manager:
		oxygen_manager.oxygen_depleted.connect(func(): _die("ASPHYXATION"))

func _process(delta):
	if not alive: return
	_moving()
	if (shift_settings.completed_tasks >= shift_settings.amount_of_tasks) and (shift_settings.shift_timer <= 0):
		_win()

func _update_camera():
	var target_y = 0.0
	var target_x = 0.0
	
	match horizontal_view:
		"left": target_y = PI/2
		"right": target_y = -PI/2
		"center": target_y = 0.0
		
	match vertical_view:
		"up": target_x = PI/4
		"down": target_x = -PI/4
		"center": target_x = 0.0
		
	_rotate_camera(target_y, target_x, start_position)

func _rotate_camera(target_y: float, target_x: float, target_pos: Vector3):
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "rotation:y", target_y, 0.2).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "rotation:x", target_x, 0.2).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position", target_pos, 0.2).set_trans(Tween.TRANS_SINE)

func _moving():
	if is_monitoring:
		if Input.is_action_just_pressed("Left") or Input.is_action_just_pressed("Right") or Input.is_action_just_pressed("Up") or Input.is_action_just_pressed("Down"):
			_exit_monitor()
		return

	if Input.is_action_just_pressed("Left"):
		if horizontal_view == "right": horizontal_view = "center"
		elif horizontal_view == "center": horizontal_view = "left"
		_update_camera()
		
	if Input.is_action_just_pressed("Right"):
		if horizontal_view == "left": horizontal_view = "center"
		elif horizontal_view == "center": horizontal_view = "right"
		_update_camera()

	if Input.is_action_just_pressed("Up"):
		if vertical_view == "down": vertical_view = "center"
		elif vertical_view == "center": vertical_view = "up"
		_update_camera()
		
	if Input.is_action_just_pressed("Down"):
		if vertical_view == "up": vertical_view = "center"
		elif vertical_view == "center": vertical_view = "down"
		_update_camera()

	if Input.is_action_just_pressed("Interact"):
		if horizontal_view == "left" and vertical_view == "center": vent.close_vent()
		elif horizontal_view == "right" and vertical_view == "center": crematory.toggle_crematory()
		elif horizontal_view == "center" and vertical_view == "up": valve.close_valve()
		elif horizontal_view == "center" and vertical_view == "center": _enter_monitor()

func _enter_monitor():
	is_monitoring = true
	monitor.set_active(true)
	var cam_transform = monitor.get_camera_transform()
	var target_rot = cam_transform.basis.get_euler()
	_rotate_camera(target_rot.y, target_rot.x, cam_transform.origin)

func _exit_monitor():
	is_monitoring = false
	monitor.set_active(false)
	horizontal_view = "center"
	vertical_view = "center"
	_update_camera()

func _unhandled_input(event):
	if is_monitoring and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_exit_monitor()

func _die(reason, killer = null):
	if not alive: return
	alive = false
	shift_settings.last_death_reason = reason.to_upper()
	
	if is_monitoring:
		_exit_monitor()

	if reason == "ASPHYXATION":
		var death_tween = create_tween().set_parallel(true)
		death_tween.tween_property(self, "rotation:z", deg_to_rad(60), 2.0).set_trans(Tween.TRANS_SINE)
		death_tween.tween_property(self, "position:y", position.y - 0.5, 2.0).set_trans(Tween.TRANS_QUAD)
		if oxygen_manager and oxygen_manager.death_fog:
			death_tween.tween_property(oxygen_manager.death_fog, "color:a", 1.0, 2.0)
		await death_tween.finished
		
	elif (reason == "RIPPER" or reason == "BLOODY") and killer != null:
		var look_target = killer.global_position
		look_target.y = global_position.y
		
		var rot_tween = create_tween()
		rot_tween.tween_method(func(pos): look_at(pos), global_position + -basis.z, look_target, 0.4)
		
		if killer.has_method("start_kill_sequence_movement"):
			await killer.start_kill_sequence_movement()
			
			if death_blood:
				var blood_tween = create_tween()
				killer.play_kill_animation()
				blood_tween.tween_property(death_blood, "color:a", 0.5, 1.0)
				
				if killer.anim_player:
					await killer.anim_player.animation_finished
				else:
					await get_tree().create_timer(1.5).timeout
		else:
			await get_tree().create_timer(2.0).timeout
	
	get_tree().change_scene_to_file("res://scenes/Death_screen.tscn")

func _win():
	alive = false
	get_tree().change_scene_to_file("res://scenes/Win_screen.tscn")
