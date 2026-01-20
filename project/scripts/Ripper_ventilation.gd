extends Node3D
class_name Vent
var is_opened = true

func close_vent():
	if is_opened:
		rotation.y = (0)
		is_opened = false

func _ready():
	pass 

func _process(delta):
	pass
