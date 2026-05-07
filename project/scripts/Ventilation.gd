extends Node3D
class_name Vent

var is_opened: bool = true

const OPEN_ANGLE = deg_to_rad(0)
const CLOSED_ANGLE = deg_to_rad(-90)

func _ready():
	rotation.y = OPEN_ANGLE if is_opened else CLOSED_ANGLE

func close_vent():
	is_opened = !is_opened
	
	var target_rotation = OPEN_ANGLE if is_opened else CLOSED_ANGLE
	
	var tween = create_tween()
	tween.tween_property(self, "rotation:y", target_rotation, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
