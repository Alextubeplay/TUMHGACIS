extends Node3D

@onready var main_menu_container = $Main_menu/Menu
@onready var difficulty_menu_container = $Main_menu/Difficulty_settings

func _ready() -> void:
	main_menu_container.show()
	difficulty_menu_container.hide()
	
	main_menu_container.get_node("Play").pressed.connect(_on_play_pressed)
	main_menu_container.get_node("Difficulty").pressed.connect(_on_difficulty_pressed)
	main_menu_container.get_node("Exit").pressed.connect(_on_exit_pressed)
	
	difficulty_menu_container.get_node("HBoxContainer/1").pressed.connect(_on_difficulty_selected.bind(1))
	difficulty_menu_container.get_node("HBoxContainer/2").pressed.connect(_on_difficulty_selected.bind(2))
	difficulty_menu_container.get_node("HBoxContainer/3").pressed.connect(_on_difficulty_selected.bind(3))
	difficulty_menu_container.get_node("Back").pressed.connect(_on_back_pressed)

func _on_play_pressed() -> void:
	if ShiftSettings:
		ShiftSettings.set_difficulty(ShiftSettings.difficulty)
	
	var target_scene = "res://scenes/Main_scene.tscn"
	get_tree().change_scene_to_file(target_scene)

func _on_difficulty_pressed() -> void:
	main_menu_container.hide()
	difficulty_menu_container.show()

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_difficulty_selected(level: int) -> void:
	if ShiftSettings:
		ShiftSettings.set_difficulty(level)
	_on_back_pressed()

func _on_back_pressed() -> void:
	difficulty_menu_container.hide()
	main_menu_container.show()
