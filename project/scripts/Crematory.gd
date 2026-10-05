extends Node3D
class_name Crematory

var is_opened: bool = true
var is_kicked: bool = false
var kick_speed: float = 30.0
var kick_direction: Vector3 = Vector3.ZERO
var interaction_locked: bool = false

const OPEN_ANGLE = deg_to_rad(270)
const CLOSED_ANGLE = deg_to_rad(180)

func _ready():
	rotation.y = OPEN_ANGLE if is_opened else CLOSED_ANGLE

func _process(delta):
	if is_kicked:
		global_position += kick_direction * kick_speed * delta

func interact():
	if not is_kicked and not interaction_locked:
		toggle_crematory()

func toggle_crematory():
	if is_kicked:
		return

	var audio_mgr = get_node_or_null("/root/AudioManager")
	if not audio_mgr:
		audio_mgr = get_node_or_null("/root/Audio_manager")
	if audio_mgr:
		audio_mgr.play_bleach_door_open()

	is_opened = !is_opened
	var target_rotation = OPEN_ANGLE if is_opened else CLOSED_ANGLE
	var tween = create_tween()
	tween.tween_property(self, "rotation:y", target_rotation, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

	if not is_opened:
		await get_tree().create_timer(3.0).timeout
		if not is_opened and not is_kicked:
			toggle_crematory()

func kick_at_player(player_pos: Vector3):
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if not audio_mgr:
		audio_mgr = get_node_or_null("/root/Audio_manager")
	if audio_mgr:
		audio_mgr.play_bleach_door_break()

	is_opened = true
	is_kicked = true
	kick_direction = (player_pos - global_position).normalized()
	kick_direction.y = 0
