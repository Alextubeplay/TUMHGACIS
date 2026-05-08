extends Node

var chance = 0.3
var hypno_position = "far"
var timer = 30.0
var kill_timer = 0.0

@onready var shift_settings = $"../Shift settings"
@onready var player = $"../Player"
@onready var hypno_indicator = $"../HUD/HypnoNear"

func _ready() -> void:
	randomize()

func _process(delta: float) -> void:
	if shift_settings.is_hypno_active:
		if timer > 0:
			timer -= delta
		else:
			timer = 30.0
		_moving(delta)
	else:
		hypno_position = "far"
		kill_timer = 0.0
	
	if hypno_position == "nearest":
		hypno_indicator.show()
	else:
		hypno_indicator.hide()

func _moving(delta: float):
	match hypno_position:
		"far":
			if randf() < chance and timer <= 0:
				hypno_position = "middle"
				timer = 30.0
		"middle":
			if randf() < chance and timer <= 0:
				hypno_position = "nearest"
				timer = 10.0
		"nearest":
			if timer > 0:
				if player.plooking == "forward" or player.plooking == "monitor":
					kill_timer += delta
					if kill_timer >= 3.0 and player.alive:
						player._die("Hypno")
				else:
					kill_timer = 0.0
			else:
				hypno_position = "far"
				kill_timer = 0.0
				timer = 30.0
