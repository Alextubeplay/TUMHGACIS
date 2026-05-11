extends Control

# Настройки игры
var goal_clicks: int = 0
var current_clicks: int = 0
var is_waiting: bool = false 
var task_done: bool = false


var start_y_position: float = 0.0
var click_offset: float = 15.0 


var color_default = Color(1, 1, 1)
var color_success = Color("195ad3")
var color_fail = Color(0, 0, 0)

@onready var goal_label = $VBoxContainer/goal_clicks
@onready var current_label = $VBoxContainer/current_clicks
@onready var main_button = $CenterContainer/Button

func _ready() -> void:
	randomize()
	reset_level()
	await get_tree().process_frame
	start_y_position = main_button.position.y

func reset_level():
	goal_clicks = randi_range(49, 120)
	current_clicks = 0
	is_waiting = false
	
	if main_button:
		main_button.position.y = start_y_position
	
	goal_label.text = str(goal_clicks)
	current_label.text = str(current_clicks)
	current_label.add_theme_color_override("font_color", color_default)

func _on_button_button_down() -> void:
	main_button.position.y = start_y_position + click_offset

func _on_button_button_up() -> void:
	main_button.position.y = start_y_position

func _on_button_pressed() -> void:
	if is_waiting or task_done:
		return
		
	current_clicks += 1
	current_label.text = str(current_clicks)
	current_label.add_theme_color_override("font_color", color_default)
	
	start_decision_countdown()

func start_decision_countdown():
	var this_click_id = current_clicks
	await get_tree().create_timer(1.0).timeout
	
	if current_clicks == this_click_id and not is_waiting:
		check_result()

func check_result():
	if current_clicks == goal_clicks:
		handle_victory()
	else:
		handle_failure()

func handle_victory():
	is_waiting = true
	var tween = create_tween()
	tween.tween_property(current_label, "theme_override_colors/font_color", color_success.lerp(color_default, 0.6), 0.4)
	tween.tween_property(current_label, "theme_override_colors/font_color", color_success.lerp(color_default, 0.3), 0.4)
	tween.tween_property(current_label, "theme_override_colors/font_color", color_success, 0.4)
	
	await tween.finished
	if not task_done:
		ShiftSettings.completed_tasks += 1
		task_done = true

func handle_failure():
	is_waiting = true 
	current_label.add_theme_color_override("font_color", color_fail)
	await get_tree().create_timer(2.0).timeout
	reset_level()
