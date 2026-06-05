extends Node3D

@export var MOUSE_SENSITIVITY: float = 0.002
@export var CAMERA_OFFSET: Vector3 = Vector3(0, 1.5, 0) # Высота камеры над началом координат игрока

var alive = true
var is_monitoring = false
var camera_x_rotation: float = 0.0

@onready var shift_settings = get_node("/root/ShiftSettings")
@onready var oxygen_manager = $Oxygen_manager
@onready var death_blood = $"../HUD/Death_blood" 

@onready var camera_raycast: RayCast3D = $SubViewportContainer/SubViewport/Camera3D/RayCast3D
@onready var camera_3d: Camera3D = $SubViewportContainer/SubViewport/Camera3D
@onready var monitor = get_node("../Monitor")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if oxygen_manager:
		oxygen_manager.oxygen_depleted.connect(func(): _die("ASPHYXATION"))

func _process(delta):
	if not alive: return
	
	# Пока мы ходим, жестко удерживаем камеру в точке игрока и синхронизируем углы поворота
	if not is_monitoring:
		camera_3d.global_position = global_position + CAMERA_OFFSET
		camera_3d.global_rotation = Vector3(camera_x_rotation, rotation.y, 0)
	
	if Input.is_action_just_pressed("Interact") and not is_monitoring:
		_check_interaction()
		
	if (shift_settings.completed_tasks >= shift_settings.amount_of_tasks) and (shift_settings.shift_timer <= 0):
		_win()

func _input(event):
	if not alive: return
	
	if is_monitoring:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_exit_monitor()
		return

	if event is InputEventMouseMotion:
		# Горизонтальное вращение самого игрока
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		
		# Безопасный расчет вертикального угла без прямого вмешательства в матрицы вьюпорта
		camera_x_rotation -= event.relative.y * MOUSE_SENSITIVITY
		camera_x_rotation = clamp(camera_x_rotation, deg_to_rad(-70), deg_to_rad(70))

func _check_interaction():
	if camera_raycast.is_colliding():
		var collider = camera_raycast.get_collider()
		var target = collider if not collider is StaticBody3D else collider.get_parent()
		
		if target == monitor:
			_enter_monitor()
			return
			
		if target.has_method("interact"):
			target.interact()

func _enter_monitor():
	is_monitoring = true
	monitor.set_active(true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	var cam_transform = monitor.get_camera_transform()
	
	# Плавный перелет к монитору через глобальные координаты
	var tween = create_tween().set_parallel(true)
	tween.tween_property(camera_3d, "global_transform", cam_transform, 0.2).set_trans(Tween.TRANS_SINE)

func _exit_monitor():
	monitor.set_active(false)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	camera_x_rotation = 0.0
	
	var target_position = global_position + CAMERA_OFFSET
	var target_rotation = Vector3(0, rotation.y, 0)
	
	# Плавно возвращаем камеру назад к лицу игрока
	var tween = create_tween().set_parallel(true)
	tween.tween_property(camera_3d, "global_position", target_position, 0.2).set_trans(Tween.TRANS_SINE)
	tween.tween_property(camera_3d, "global_rotation", target_rotation, 0.2).set_trans(Tween.TRANS_SINE)
	
	# Только когда анимация возврата ПОЛНОСТЬЮ завершена, возвращаем управление игроку в _process
	await tween.finished
	is_monitoring = false

func _die(reason, killer = null):
	if not alive: return
	alive = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	shift_settings.last_death_reason = reason.to_upper()
	
	if is_monitoring:
		is_monitoring = false

	if reason == "ASPHYXATION":
		var death_tween = create_tween().set_parallel(true)
		death_tween.tween_property(self, "rotation:z", deg_to_rad(60), 2.0).set_trans(Tween.TRANS_SINE)
		death_tween.tween_property(self, "position:y", position.y - 0.5, 2.0).set_trans(Tween.TRANS_QUAD)
		if oxygen_manager and oxygen_manager.death_fog:
			death_tween.tween_property(oxygen_manager.death_fog, "color:a", 1.0, 2.0)
		await death_tween.finished
		
	elif (reason == "BLEACH" or reason == "BLOODY" or reason == "RIPPER") and killer != null:
		var look_target = killer.global_position
		look_target.y = global_position.y
		
		var rot_tween = create_tween()
		rot_tween.tween_method(func(pos): look_at(pos), global_position + -basis.z, look_target, 0.4)
		await rot_tween.finished
		
		if killer.has_method("start_kill_sequence_movement"):
			await killer.start_kill_sequence_movement()
			if death_blood:
				var blood_tween = create_tween()
				blood_tween.tween_property(death_blood, "color:a", 0.5, 0.2)
			if killer.has_method("play_kill_animation"):
				killer.play_kill_animation()
				if killer.anim_player:
					await killer.anim_player.animation_finished
				else:
					await get_tree().create_timer(1.5).timeout
		else:
			await get_tree().create_timer(2.0).timeout
	
	get_tree().change_scene_to_file("res://scenes/Death_screen.tscn")

func _win():
	alive = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://scenes/Win_screen.tscn")
