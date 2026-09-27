extends Node3D

var is_opened: bool = true
var interaction_locked: bool = false

const OPEN_ANGLE = deg_to_rad(0)
const CLOSED_ANGLE = deg_to_rad(-90)

func _ready():
	rotation.y = OPEN_ANGLE if is_opened else CLOSED_ANGLE

func interact():
	if interaction_locked: return
	_toggle_door()

func open_vent():
	if not is_opened:
		_toggle_door()

func close_vent():
	if is_opened:
		_toggle_door()

func _toggle_door():
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if not audio_mgr:
		audio_mgr = get_node_or_null("/root/Audio_manager")
	if audio_mgr:
		audio_mgr.play_bleach_door_open()
		
	is_opened = !is_opened
	var target_rotation = OPEN_ANGLE if is_opened else CLOSED_ANGLE
	var tween = create_tween()
	tween.tween_property(self, "rotation:y", target_rotation, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func kick_at_player(player_position: Vector3):
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if not audio_mgr:
		audio_mgr = get_node_or_null("/root/Audio_manager")
	if audio_mgr:
		audio_mgr.play_bleach_door_break()
		
	is_opened = true
	var tween = create_tween()
	tween.tween_property(self, "rotation:y", OPEN_ANGLE + deg_to_rad(60), 0.15).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
