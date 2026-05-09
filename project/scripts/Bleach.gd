extends Node

var chance = 0.8
var bleach_position = "far"
var timer = 20.0
var is_processing_closure = false

@onready var shift_settings = $"../Shift settings"
@onready var crematory = $"../Crematory"
@onready var player = $"../Player"
@onready var bleach_indicator = $"../HUD/BleachNear"

func _ready() -> void:
	randomize()

func _process(delta: float) -> void:
	if not shift_settings.is_bleach_active:
		return

	if not crematory.is_opened:
		if not is_processing_closure:
			is_processing_closure = true
			_check_door_consequence()
		return 
	else:
		is_processing_closure = false

	if timer > 0:
		timer -= delta
	
	_logic()

	if bleach_position == "nearest":
		bleach_indicator.show()
	else:
		bleach_indicator.hide()

func _check_door_consequence():
	if bleach_position == "near" or bleach_position == "nearest":
		bleach_position = "far"
		timer = 20.0
	elif bleach_position == "far" or bleach_position == "middle":
		if player.alive:
			player._die("Bleach (closed door too early)")
	
	bleach_indicator.hide()

func _logic():
	match bleach_position:
		"far":
			if randf() < chance and timer <= 0:
				bleach_position = "middle"
				timer = 20.0
		"middle":
			if randf() < (chance * 0.5) and timer <= 0:
				bleach_position = "near"
				timer = 20.0
		"near":
			if randf() < (chance * 0.25) and timer <= 0:
				bleach_position = "nearest"
				timer = 20.0
		"nearest":
			if timer <= 10.0 and player.alive:
				player._die("Bleach")
				timer = 30.0
