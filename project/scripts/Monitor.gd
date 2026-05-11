extends Node3D

@onready var monitor_light = $Monitor_light
@onready var monitor_hud = $Monitor_hud
@onready var camera_pivot = $Camera_point

func _ready():
	if monitor_light:
		monitor_light.light_energy = 0
	if monitor_hud:
		monitor_hud.hide()

func set_active(is_on: bool):
	if monitor_light:
		var target_energy = 16.0 if is_on else 0.0
		var tween = create_tween()
		tween.tween_property(monitor_light, "light_energy", target_energy, 0.25)
	
	if monitor_hud:
		if is_on:
			monitor_hud.show()
		else:
			monitor_hud.hide()

func get_camera_transform() -> Transform3D:
	return camera_pivot.global_transform
