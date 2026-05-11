extends Node3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _on_restart_pressed():
	queue_free()
	get_tree().change_scene_to_file("res://scenes/Main_menu.tscn")
