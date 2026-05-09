extends Node3D

@onready var death_env = $WorldEnvironment

@onready var label = $Death/Death_label

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if label:
		label.text = "YOU DIED OF: " + ShiftSettings.last_death_reason
	
	if death_env and death_env.environment:
		death_env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_DISABLED
		
		var camera = get_viewport().get_camera_3d()
		if camera:
			camera.environment = death_env.environment

func _on_restart_pressed():
	get_tree().change_scene_to_file("res://scenes/Main_menu.tscn")
