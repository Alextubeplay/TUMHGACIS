extends Node3D

@onready var main_menu_container = $Main_menu/Menu
@onready var difficulty_menu_container = $Main_menu/Difficulty_settings
@onready var how_to_play_menu_container = $Main_menu/How_to_play_menu
@onready var credits_menu_container = $Main_menu/Credits_menu

func _ready() -> void:
	main_menu_container.show()
	difficulty_menu_container.hide()
	how_to_play_menu_container.hide()
	credits_menu_container.hide()
	
	main_menu_container.get_node("Play").pressed.connect(_on_play_pressed)
	main_menu_container.get_node("Difficulty").pressed.connect(_on_difficulty_pressed)
	main_menu_container.get_node("How_to_play").pressed.connect(_on_how_to_play_pressed)
	main_menu_container.get_node("Credits").pressed.connect(_on_credits_pressed)
	main_menu_container.get_node("Exit").pressed.connect(_on_exit_pressed)
	
	difficulty_menu_container.get_node("HBoxContainer/1").pressed.connect(_on_difficulty_selected.bind(1))
	difficulty_menu_container.get_node("HBoxContainer/2").pressed.connect(_on_difficulty_selected.bind(2))
	difficulty_menu_container.get_node("HBoxContainer/3").pressed.connect(_on_difficulty_selected.bind(3))
	difficulty_menu_container.get_node("Back").pressed.connect(_on_back_pressed)
	
	how_to_play_menu_container.get_node("Back").pressed.connect(_on_how_to_play_back_pressed)
	credits_menu_container.get_node("Back").pressed.connect(_on_credits_back_pressed)
	
	_update_difficulty_colors()

func _on_play_pressed() -> void:
	if ShiftSettings:
		ShiftSettings.set_difficulty(ShiftSettings.difficulty)
	
	var target_scene = "res://scenes/Main_scene.tscn"
	get_tree().change_scene_to_file(target_scene)

func _on_difficulty_pressed() -> void:
	main_menu_container.hide()
	difficulty_menu_container.show()
	_update_difficulty_colors()

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_difficulty_selected(level: int) -> void:
	if ShiftSettings:
		ShiftSettings.set_difficulty(level)
	_update_difficulty_colors()
	_on_back_pressed()

func _on_back_pressed() -> void:
	difficulty_menu_container.hide()
	main_menu_container.show()

func _on_how_to_play_pressed() -> void:
	main_menu_container.hide()
	how_to_play_menu_container.show()

func _on_how_to_play_back_pressed() -> void:
	how_to_play_menu_container.hide()
	main_menu_container.show()

func _on_credits_pressed() -> void:
	main_menu_container.hide()
	credits_menu_container.show()

func _on_credits_back_pressed() -> void:
	credits_menu_container.hide()
	main_menu_container.show()

func _update_difficulty_colors() -> void:
	if not ShiftSettings:
		return
	var current_diff = ShiftSettings.difficulty
	
	var active_color = Color.from_hsv(0.12, 0.8, 1.0)
	var inactive_color = Color.from_hsv(0.12, 0.2, 0.4)
	
	for i in range(1, 4):
		var btn = difficulty_menu_container.get_node("HBoxContainer/" + str(i))
		if btn:
			var color = active_color if i == current_diff else inactive_color
			btn.add_theme_color_override("font_color", color)
			btn.add_theme_color_override("font_hover_color", color)
			btn.add_theme_color_override("font_pressed_color", color)
			btn.add_theme_color_override("font_focus_color", color)
