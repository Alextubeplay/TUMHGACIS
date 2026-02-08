extends Node3D
class_name Valve
var is_opened = true

func close_valve():
	if is_opened:
		$AnimationPlayer.play("Rotate")
		is_opened = false

func _ready():
	pass 

func _process(delta):
	pass
