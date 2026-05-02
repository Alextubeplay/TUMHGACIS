extends Node
class_name Shift_settings

# Gameplay modifiers
var shift_timer = 180.0 # Seconds
var amount_of_tasks = 4
var completed_tasks = 0:
	set(value):
		if value <= amount_of_tasks:
			completed_tasks = value
		else:
			completed_tasks = amount_of_tasks

var difficulty = 1

# Gameplay Features
var is_shift_timer_active = true
var is_tasks_active = true
var is_breathing_active = true
var is_ripper_active = true
var is_valve_active = true

# Technical
func _process(delta):
	if is_shift_timer_active and shift_timer > 0:
		shift_timer -= delta
		if shift_timer <= 0:
			shift_timer = 0
