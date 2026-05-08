extends Node3D
class_name Crematory

var is_opened: bool = true

const OPEN_ANGLE = deg_to_rad(270)
const CLOSED_ANGLE = deg_to_rad(180)

func _ready():
	rotation.y = OPEN_ANGLE if is_opened else CLOSED_ANGLE

func toggle_crematory():
	is_opened = !is_opened
	
	var target_rotation = OPEN_ANGLE if is_opened else CLOSED_ANGLE
	
	var tween = create_tween()
	tween.tween_property(self, "rotation:y", target_rotation, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	
	if not is_opened:
		await get_tree().create_timer(3.0).timeout
		if not is_opened:
			toggle_crematory()
