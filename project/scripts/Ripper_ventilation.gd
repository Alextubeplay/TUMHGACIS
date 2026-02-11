extends Node3D
class_name Vent

var is_opened = true
var chance = 0.3 #30%
var ripper_position = "far" #far, middle, near, nearest
var timer = 30

@onready var player = $"../Player"

func _process(delta):
	
	if is_opened:
		timer -= delta
		_moving()
	else:
		ripper_position = "far"

func close_vent():
	if is_opened:
		rotation.y = (0)
		is_opened = false
	else:
		rotation.y = (90)
		is_opened = true

func _ready():
	pass 

func _moving():
	match ripper_position:
		"far":
			if randf() < chance and timer <=0:
				ripper_position = "middle"
				print(ripper_position)
				timer = 30
		"middle":
			if randf() < (chance * 2) and timer <=0:
				ripper_position = "near"
				timer = 30
		"near":
			if randf() < (chance * 2.5) and timer <=0:
				ripper_position = "nearest"
				timer = 30
		"nearest":
			if timer <= 20:
				player._die("Ripper")
				timer = 30
