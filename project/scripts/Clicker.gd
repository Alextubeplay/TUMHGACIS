extends Control

# Настройки игры
var goal_clicks: int = 0
var current_clicks: int = 0
var is_waiting: bool = false 
var task_done: bool = false

# Таймер ожидания после последнего клика
var decision_timer: SceneTreeTimer = null

# Цвета
var color_default = Color(1, 1, 1)    # Белый
var color_success = Color("195ad3")  # Синий
var color_fail = Color(0, 0, 0)      # Черный

@onready var goal_label = $VBoxContainer/goal_clicks
@onready var current_label = $VBoxContainer/current_clicks

func _ready() -> void:
	randomize()
	reset_level()

func reset_level():
	goal_clicks = randi_range(59, 200)
	current_clicks = 0
	is_waiting = false
	decision_timer = null
	
	goal_label.text = str(goal_clicks)
	current_label.text = str(current_clicks)
	current_label.add_theme_color_override("font_color", color_default)

func _on_button_pressed() -> void:
	if is_waiting or task_done:
		return
		
	current_clicks += 1
	current_label.text = str(current_clicks)
	
	# Сбрасываем цвет на белый, если игрок кликает (на случай, если началась анимация)
	current_label.add_theme_color_override("font_color", color_default)
	
	# ЗАПУСК/СБРОС ТАЙМЕРА ПРИ КАЖДОМ КЛИКЕ
	# Мы создаем новый таймер на 1 секунду. 
	# Если нажать кнопку еще раз, старый таймер нам станет не важен.
	start_decision_countdown()

func start_decision_countdown():
	# Создаем уникальный ID для этого замера
	var this_click_id = current_clicks
	
	# Ждем 1 секунду после последнего клика
	await get_tree().create_timer(1.0).timeout
	
	# Если за эту секунду количество кликов НЕ изменилось, значит игрок остановился
	if current_clicks == this_click_id and not is_waiting:
		check_result()

func check_result():
	if current_clicks == goal_clicks:
		handle_victory()
	else:
		# Если меньше ИЛИ больше цели — это проигрыш
		handle_failure()

func handle_victory():
	is_waiting = true # Теперь блокируем клики, игрок победил
	
	var tween = create_tween()
	# 3 этапа перехода в синий
	tween.tween_property(current_label, "theme_override_colors/font_color", color_success.lerp(color_default, 0.6), 0.4)
	tween.tween_property(current_label, "theme_override_colors/font_color", color_success.lerp(color_default, 0.3), 0.4)
	tween.tween_property(current_label, "theme_override_colors/font_color", color_success, 0.4)
	
	await tween.finished
	await get_tree().create_timer(0.5).timeout
	
	if not task_done:
		ShiftSettings.completed_tasks += 1
		task_done = true

func handle_failure():
	is_waiting = true # Блокируем ввод на время показа ошибки
	
	# Теперь ВСЕГДА чернеет при неверном результате
	current_label.add_theme_color_override("font_color", color_fail)
	
	await get_tree().create_timer(2.0).timeout
	reset_level()
