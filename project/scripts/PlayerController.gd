extends Node3D
class_name Player

var plooking = "forward"
var cooldown = 0.2
var alive = true
var start_position: Vector3
var monitor_offset = Vector3(0.3, -1.5, -3.7)

@onready var shift_settings = $"../Shift settings"
@onready var valve = $"../Valve"
@onready var vent = $"../Ventilation"
@onready var crematory = $"../Crematory"
@onready var o2_bar = $"../HUD/O2_bar"
@onready var o2_percent = $"../HUD/O2_bar_percent"

@onready var monitor_light = $"../Monitor_light"
@onready var monitor_hud = $"../Monitor"

func _ready():
	start_position = position
	if monitor_light:
		monitor_light.light_energy = 0
	if monitor_hud:
		monitor_hud.hide()

func _process(delta):
	if cooldown > 0:
		cooldown -= delta
	
	_moving()
	_breath(vent.is_opened)

func _rotate_camera(target_rotation_y: float, target_rotation_x: float, offset_pos: Vector3 = Vector3.ZERO):
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "rotation:y", target_rotation_y, 0.25).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "rotation:x", target_rotation_x, 0.25).set_trans(Tween.TRANS_SINE)
	
	var final_pos = start_position + offset_pos
	tween.tween_property(self, "position", final_pos, 0.25).set_trans(Tween.TRANS_SINE)
	return tween

func _toggle_monitor_light(is_on: bool):
	if monitor_light:
		var target_energy = 16.0 if is_on else 0.0
		var tween = create_tween()
		tween.tween_property(monitor_light, "light_energy", target_energy, 0.25)

func _toggle_monitor_hud(is_on: bool):
	if monitor_hud:
		if is_on:
			monitor_hud.show()
		else:
			monitor_hud.hide()

func _unhandled_input(event):
	if plooking == "monitor" and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			plooking = "forward"
			_toggle_monitor_light(false)
			_toggle_monitor_hud(false)
			_rotate_camera(0, 0, Vector3.ZERO)

func _moving():
	if Input.is_action_just_pressed("Left"):
		match plooking:
			"forward", "up", "down":
				plooking = "left"
				_rotate_camera(PI / 2, 0)
			"right":
				plooking = "forward"
				_rotate_camera(0, 0)
			"monitor":
				plooking = "left"
				_toggle_monitor_light(false)
				_toggle_monitor_hud(false)
				_rotate_camera(PI / 2, 0, Vector3.ZERO)

	if Input.is_action_just_pressed("Right"):
		match plooking:
			"forward", "up", "down":
				plooking = "right"
				_rotate_camera(-PI / 2, 0)
			"left":
				plooking = "forward"
				_rotate_camera(0, 0)
			"monitor":
				plooking = "right"
				_toggle_monitor_light(false)
				_toggle_monitor_hud(false)
				_rotate_camera(-PI / 2, 0, Vector3.ZERO)

	if Input.is_action_just_pressed("Up"):
		match plooking:
			"forward":
				plooking = "up"
				_rotate_camera(0, PI / 4)
			"left", "right":
				plooking = "up"
				_rotate_camera(0, PI / 4)
			"down":
				plooking = "forward"
				_rotate_camera(0, 0)
			"monitor":
				plooking = "forward"
				_toggle_monitor_light(false)
				_toggle_monitor_hud(false)
				_rotate_camera(0, 0, Vector3.ZERO)

	if Input.is_action_just_pressed("Down"):
		match plooking:
			"forward":
				plooking = "down"
				_rotate_camera(0, -PI / 4)
			"left", "right":
				plooking = "down"
				_rotate_camera(0, -PI / 4)
			"up":
				plooking = "forward"
				_rotate_camera(0, 0)
			"monitor":
				plooking = "forward"
				_toggle_monitor_light(false)
				_toggle_monitor_hud(false)
				_rotate_camera(0, 0, Vector3.ZERO)

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
				plooking = "monitor"
				_toggle_monitor_light(true)
				var tw = _rotate_camera(0, -0.3, monitor_offset)
				tw.finished.connect(func(): if plooking == "monitor": _toggle_monitor_hud(true))

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
	var death_scene = preload("res://scenes/Death_screen.tscn").instantiate()
	get_tree().root.add_child(death_scene)
	
	var label = death_scene.get_node("CanvasLayer/Placeholder_death")
	if label:
		label.text = "YOU DIED OF: " + reason.to_upper()
	
	queue_free()
