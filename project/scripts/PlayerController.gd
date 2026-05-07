extends Node3D
class_name Player

var plooking = "forward"
var cooldown = 0.2
var alive = true

# Добавляем переменную для хранения начальной позиции
var start_position: Vector3

@onready var shift_settings = $"../Shift settings"
@onready var valve = $"../Valve"
@onready var vent = $"../Ventilation"
@onready var o2_bar = $"../HUD/O2_bar"
@onready var o2_percent = $"../HUD/O2_bar_percent"
@onready var placeholder_death = $"../Death_screen/Placeholder_death"

func _ready():
	# Запоминаем, где игрок стоит в редакторе
	start_position = position

func _process(delta):
	if cooldown > 0:
		cooldown -= delta
	
	_moving()
	_breath(vent.is_opened)

func _rotate_camera(target_rotation_y: float, target_rotation_x: float, offset_pos: Vector3 = Vector3.ZERO):
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "rotation:y", target_rotation_y, 0.25).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "rotation:x", target_rotation_x, 0.25).set_trans(Tween.TRANS_SINE)
	
	# Теперь мы прибавляем смещение к начальной позиции
	var final_pos = start_position + offset_pos
	tween.tween_property(self, "position", final_pos, 0.25).set_trans(Tween.TRANS_SINE)

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
				plooking = "forward"
				_rotate_camera(0, 0, Vector3.ZERO)

	if Input.is_action_just_pressed("Right"):
		match plooking:
			"forward", "up", "down":
				plooking = "right"
				_rotate_camera(-PI / 2, 0)
			"left":
				plooking = "forward"
				_rotate_camera(0, 0)
			"monitor":
				plooking = "forward"
				_rotate_camera(0, 0, Vector3.ZERO)

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

	if Input.is_action_just_pressed("Interact"):
		match plooking:
			"left":
				vent.close_vent()
			"up":
				valve.close_valve()
			"forward":
				plooking = "monitor"
				# Смещение относительно старта: 0.2 вперед (Z) и -0.2 вниз (Y)
				_rotate_camera(0, -0.2, Vector3(0, -0.2, 0.2))
			"monitor":
				plooking = "forward"
				_rotate_camera(0, 0, Vector3.ZERO)

func _breath(vent_opened):
	if cooldown <= 0 and alive and shift_settings.is_breathing_active:
		if vent_opened:
			o2_bar.value += 2.5
		else:
			o2_bar.value -= 0.33
		cooldown = 0.2
	
	o2_percent.text = str(snapped(o2_bar.value, 0.1)) + "%"
	
	if o2_bar.value <= 0:
		_die("Asphyxation")

func _die(reason):
	placeholder_death.text = "you died of: " + reason
	alive = false
