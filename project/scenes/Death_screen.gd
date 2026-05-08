extends Node3D

@onready var death_env = $WorldEnvironment

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if death_env and death_env.environment:
		death_env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_DISABLED
		
		var camera = get_viewport().get_camera_3d()
		if camera:
			camera.environment = death_env.environment

func _on_restart_pressed():
	queue_free() 
	get_tree().change_scene_to_file("res://scenes/Main_menu.tscn")
