extends Node3D

var plooking = "forward"
var cooldown = 0.2
var alive = true
var start_position: Vector3

@onready var shift_settings = get_node("/root/ShiftSettings")
@onready var valve = $"../Valve"
@onready var vent = $"../Ventilation"
@onready var crematory = $"../Crematory"
@onready var o2_bar = $"../HUD/O2_bar"
@onready var o2_percent = $"../HUD/O2_bar_percent"
@onready var monitor = $"../Monitor"

func _ready():
	start_position = position

func _process(delta):
	if cooldown > 0:
		cooldown -= delta
	_moving()
	_breath(vent.is_opened)
	if (shift_settings.completed_tasks >= shift_settings.amount_of_tasks) and (shift_settings.shift_timer <= 0) and (alive == true):
		_win()

func _rotate_camera(target_rotation_y: float, target_rotation_x: float, target_pos: Vector3):
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "rotation:y", target_rotation_y, 0.25).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "rotation:x", target_rotation_x, 0.25).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position", target_pos, 0.25).set_trans(Tween.TRANS_SINE)
	return tween

func _unhandled_input(event):
	if plooking == "monitor" and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_exit_monitor()

func _exit_monitor():
	plooking = "forward"
	monitor.set_active(false)
	_rotate_camera(0, 0, start_position)

func _moving():
	if Input.is_action_just_pressed("Left"):
		if plooking == "monitor":
			_exit_monitor()
			return
		match plooking:
			"forward", "up", "down":
				plooking = "left"
				_rotate_camera(PI / 2, 0, start_position)
			"right":
				plooking = "forward"
				_rotate_camera(0, 0, start_position)
	if Input.is_action_just_pressed("Right"):
		if plooking == "monitor":
			_exit_monitor()
			return
		match plooking:
			"forward", "up", "down":
				plooking = "right"
				_rotate_camera(-PI / 2, 0, start_position)
			"left":
				plooking = "forward"
				_rotate_camera(0, 0, start_position)
	if Input.is_action_just_pressed("Up"):
		if plooking == "monitor":
			_exit_monitor()
			return
		match plooking:
			"forward", "left", "right":
				plooking = "up"
				_rotate_camera(rotation.y, PI / 4, start_position)
			"down":
				plooking = "forward"
				_rotate_camera(rotation.y, 0, start_position)
	if Input.is_action_just_pressed("Down"):
		if plooking == "monitor":
			_exit_monitor()
			return
		match plooking:
			"forward", "left", "right":
				plooking = "down"
				_rotate_camera(rotation.y, -PI / 4, start_position)
			"up":
				plooking = "forward"
				_rotate_camera(rotation.y, 0, start_position)
	if Input.is_action_just_pressed("Interact"):
		if plooking == "monitor":
			return
		match plooking:
			"left":
				vent.close_vent()
			"right":
				crematory.toggle_crematory()
			"up":
				valve.close_valve()
			"forward":
				_enter_monitor()

func _enter_monitor():
	plooking = "monitor"
	monitor.set_active(true)
	var cam_transform = monitor.get_camera_transform()
	var target_rot = cam_transform.basis.get_euler()
	_rotate_camera(target_rot.y, target_rot.x, cam_transform.origin)

func _breath(vent_opened):
	if cooldown <= 0 and alive and shift_settings.is_breathing_active:
		if vent_opened:
			o2_bar.value += 1.0
		else:
			o2_bar.value -= 0.70
		cooldown = 0.2
	o2_percent.text = str(snapped(o2_bar.value, 0.1)) + "%"
	if o2_bar.value <= 0:
		_die("ASPHYXATION")

func _die(reason):
	alive = false
	shift_settings.last_death_reason = reason.to_upper()
	get_tree().change_scene_to_file("res://scenes/Death_screen.tscn")

func _win():
	alive = false
	get_tree().change_scene_to_file("res://scenes/Win_screen.tscn")
