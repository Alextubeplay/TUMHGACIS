extends Node3D

@onready var shift_settings = $"../Shift settings"
@onready var valve_indicator = $"../HUD/ValveOpen"

var is_opened = false
var timer = 1.0
var chance = 0.0047
var pushes = 1
var activations = 2

func _process(delta):
	if !is_opened:
		if timer > 0:
			timer -= delta
		else:
			timer = 1.0
			if randf() < chance and activations > 0 and shift_settings.is_valve_active:
				is_opened = true
				pushes = randi_range(2, 6)
				activations -= 1
				timer = 30
	
	if is_opened:
		valve_indicator.show()
	else:
		valve_indicator.hide()

# Метод, который вызывает игрок при нажатии кнопки взаимодействия
func interact():
	if is_opened:
		close_valve()

func close_valve():
	if is_opened and $AnimationPlayer.current_animation == "":
		if pushes < 1:
			$AnimationPlayer.play("Rotate")
			is_opened = false
		else:
			$AnimationPlayer.play("Push")
			pushes -= 1
