extends Control

var map: Control
var exit_button: Control
var viewer_camera: Camera3D
var camera_display: Control

func _ready() -> void:
	await get_tree().process_frame
	_find_nodes()

	if camera_display:
		camera_display.hide()
		camera_display.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if map:
		map.show()
		var count := _connect_buttons_recursive(map)
		print("СИСТЕМА КАМЕР: Подключено кнопок: ", count)

	if exit_button:
		exit_button.hide()
		if not exit_button.gui_input.is_connected(_on_exit_gui_input):
			exit_button.gui_input.connect(_on_exit_gui_input)

func _find_nodes() -> void:
	map = find_child("Map", true, false)
	exit_button = find_child("Exit_camera", true, false)
	camera_display = find_child("SubViewportContainer", true, false)

	if camera_display:
		viewer_camera = camera_display.find_child("ViewerCamera", true, false)

func _connect_buttons_recursive(node: Node) -> int:
	var count := 0
	if not node: return 0
	
	for child in node.get_children():
		if child is BaseButton:
			# ИСПРАВЛЕНИЕ: bind передает аргументы без массива
			if child.pressed.is_connected(_on_camera_pressed):
				child.pressed.disconnect(_on_camera_pressed)
			
			child.pressed.connect(_on_camera_pressed.bind(child.name))
			child.mouse_filter = Control.MOUSE_FILTER_STOP
			count += 1
		count += _connect_buttons_recursive(child)
	return count

func _on_camera_pressed(cam_name: String) -> void:
	print("--- ПОИСК КАМЕРЫ: ", cam_name, " ---")

	var world_root = get_tree().current_scene
	if not world_root:
		print("ОШИБКА: current_scene не найден!")
		return

	# Ищем точку по имени (Camera_1, Camera_2 и т.д.)
	var camera_point = world_root.find_child(cam_name, true, false)
	
	if not camera_point:
		print("ОШИБКА: Объект с именем ", cam_name, " не найден в Main_scene!")
		return

	var actual_cam: Camera3D = null

	# Проверяем, не является ли сам найденный узел камерой
	if camera_point is Camera3D:
		actual_cam = camera_point
	else:
		# Если нет, ищем Camera3D внутри него (самый надежный способ)
		actual_cam = camera_point.find_child("Camera3D", true, false)
		
		# Если по имени не нашли, ищем любой узел типа Camera3D внутри
		if not actual_cam:
			var cams = camera_point.find_children("*", "Camera3D", true, false)
			if cams.size() > 0:
				actual_cam = cams[0]

	if actual_cam and viewer_camera:
		# ПЕРЕКЛЮЧЕНИЕ
		viewer_camera.global_transform = actual_cam.global_transform
		viewer_camera.make_current()
		
		if map: map.hide()
		if camera_display: camera_display.show()
		if exit_button: exit_button.show()
		print("УСПЕХ: Камера ", cam_name, " активирована.")
	else:
		print("КРИТИЧЕСКИЙ СБОЙ: Внутри ", cam_name, " нет Camera3D или не найдена ViewerCamera!")

func _on_exit_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_exit_pressed()

func _on_exit_pressed() -> void:
	print("ВОЗВРАТ НА КАРТУ")
	if camera_display: camera_display.hide()
	if exit_button: exit_button.hide()
	if map: map.show()
