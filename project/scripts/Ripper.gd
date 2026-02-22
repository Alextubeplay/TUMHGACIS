extends Node

var chance = 0.3 #30%
var ripper_position = "far" #far, middle, near, nearest
var timer = 30

@onready var vent = $"../Ventilation"

@onready var player = $"../Player"

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
		
	if vent.is_opened:
		if timer >0 :
			timer -= delta
		_moving()
	else:
		ripper_position = "far"

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
