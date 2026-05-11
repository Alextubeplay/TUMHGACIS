extends Node

signal oxygen_depleted

@export var o2_bar: TextureProgressBar
@export var o2_percent: Label
@export var death_fog: ColorRect

@export var max_oxygen: float = 100.0
@export var current_oxygen: float = 100.0
@export var recovery_rate: float = 1.0
@export var depletion_rate: float = 0.70
@export var tick_speed: float = 0.2

var cooldown: float = 0.0

@onready var shift_settings = get_node("/root/ShiftSettings")

func _process(delta):
	if cooldown > 0:
		cooldown -= delta
		return
	
	if shift_settings.is_breathing_active:
		_process_breathing()
		_update_ui()
		_update_visual_effects()
		cooldown = tick_speed

func _process_breathing():
	var vents = get_tree().get_nodes_in_group("vents")
	var vent_is_opened = false
	if vents.size() > 0:
		vent_is_opened = vents[0].is_opened
	
	if vent_is_opened:
		current_oxygen = move_toward(current_oxygen, max_oxygen, recovery_rate)
	else:
		current_oxygen = move_toward(current_oxygen, 0.0, depletion_rate)
	
	if current_oxygen <= 0:
		oxygen_depleted.emit()

func _update_ui():
	if o2_bar:
		o2_bar.value = current_oxygen
	if o2_percent:
		o2_percent.text = str(snapped(current_oxygen, 0.1)) + "%"

func _update_visual_effects():
	if death_fog:
		if current_oxygen < 20.0:
			var alpha = remap(current_oxygen, 20.0, 0.0, 0.0, 0.8)
			death_fog.color.a = alpha
		else:
			death_fog.color.a = 0.0
