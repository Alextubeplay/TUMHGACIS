extends Node3D
class_name Vent

var is_opened = true

func _process(delta):
	pass

func close_vent():
	if is_opened:
		rotation.y = (0)
		is_opened = false
	else:
		rotation.y = (90)
		is_opened = true

func _ready():
	pass 
