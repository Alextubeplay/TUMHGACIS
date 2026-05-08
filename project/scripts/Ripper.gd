extends Node

var chance = 0.3
var ripper_position = "far"
var timer = 30.0

@onready var shift_settings = $"../Shift settings"
@onready var vent = $"../Ventilation"
@onready var player = $"../Player"
@onready var ripper_indicator = $"../HUD/RipperNear"

func _ready() -> void:
	randomize()

func _process(delta: float) -> void:
	if vent.is_opened and shift_settings.is_ripper_active:
		if timer > 0:
			timer -= delta
		else:
			timer = 30.0
		_moving()
	else:
		ripper_position = "far"
	
	if ripper_position == "nearest":
		ripper_indicator.show()
	else:
		ripper_indicator.hide()

func _moving():
	match ripper_position:
		"far":
			if randf() < chance and timer <= 0:
				ripper_position = "middle"
				timer = 30.0
		"middle":
			if randf() < (chance * 2) and timer <= 0:
				ripper_position = "near"
				timer = 30.0
		"near":
			if randf() < (chance * 2.5) and timer <= 0:
				ripper_position = "nearest"
				timer = 30.0
		"nearest":
			if timer <= 20 and player.alive:
				player._die("Ripper")
				timer = 30.0
