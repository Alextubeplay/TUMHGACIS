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
	
	# Выход из монитора по твоей клавише "Escape" из Input Map
	if event.is_action_pressed("Escape"):
		if is_monitoring:
			exit_monitor()
			get_viewport().set_input_as_handled() # Поглощаем нажатие, чтобы не открывалось меню паузы
			return
		else:
			# Логика для открытия меню паузы, когда игрок НЕ в мониторе
			# _open_pause_menu()
			pass

	if is_monitoring:
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
	
	# Телепортируем мышь ровно в центр экрана, чтобы при открытии монитора 
	# курсор случайно не оказался на границе HoverExitZone
	var screen_size = get_viewport().get_visible_rect().size
	get_viewport().warp_mouse(screen_size / 2)
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	var cam_transform = monitor.get_camera_transform()
	
	# Плавный перелет к монитору через глобальные координаты
	var tween = create_tween().set_parallel(true)
	tween.tween_property(camera_3d, "global_transform", cam_transform, 0.2).set_trans(Tween.TRANS_SINE)

# Метод вызывается как по нажатию Escape, так и из скрипта HoverExitZone
func exit_monitor():
	# ПЕРЕД закрытием зачищаем все активные UI менеджеры, чтобы они не зависали
	if monitor and "monitor_hud" in monitor and monitor.monitor_hud:
		var hud = monitor.monitor_hud
		
		# 1. Сбрасываем мини-игры в Tasks_manager
		var tasks_manager = hud.find_child("Tasks_manager", true, false)
		if tasks_manager and tasks_manager.has_method("clear_tasks"):
			tasks_manager.clear_tasks()
			tasks_manager.current_game_path = ""
			tasks_manager.last_completed_count = ShiftSettings.completed_tasks
		
		# 2. Выключаем активный режим камер в Cameras_manager, возвращая карту
		var cameras_manager = hud.find_child("Cameras_manager", true, false)
		if cameras_manager:
			var exit_cam_btn = cameras_manager.find_child("Exit_camera", true, false)
			if exit_cam_btn and exit_cam_btn.visible:
				if "map" in cameras_manager and cameras_manager.map: cameras_manager.map.show()
				if "camera_display" in cameras_manager and cameras_manager.camera_display: cameras_manager.camera_display.hide()
				exit_cam_btn.hide()

	# Отключаем 3D объект монитора и прячем худ
	monitor.set_active(false)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	camera_x_rotation = 0.0
	
	var target_position = global_position + CAMERA_OFFSET
	var target_rotation = Vector3(0, rotation.y, 0)
	
	# Плавно возвращаем камеру назад к лицу игрока
	var tween = create_tween().set_parallel(true)
	tween.tween_property(camera_3d, "global_position", target_position, 0.2).set_trans(Tween.TRANS_SINE)
	tween.tween_property(camera_3d, "global_rotation", target_rotation, 0.2).set_trans(Tween.TRANS_SINE)
	
	# Только когда анимация возврата ПОЛНОСТЬЮ завершена, возвращаем управление игроку
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
