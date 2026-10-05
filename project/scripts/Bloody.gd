extends Node3D

@export var KILL_DISTANCE: float = 2.0
@export var MOVE_SPEED: float = 12.5
@export var FLOOR_Y: float = 0.0

var timer = 10.0
var kill_timer_base = 10.0

@onready var valve = $"../Valve"
@onready var player = $"../Player"
@onready var anim_player = $Bloody2/AnimationPlayer

func _ready() -> void:
	hide()
	var row: Dictionary = Database.get_mob_by_name("Bloody")
	if not row.is_empty():
		kill_timer_base = float(row["kill_timer"])
		timer = kill_timer_base

func _process(delta: float) -> void:
	if not player.alive: return

	if valve.is_opened:
		if timer > 0:
			timer -= delta
		_go_to_player()
	else:
		timer = kill_timer_base
		hide()

func _go_to_player():
	if timer <= 0 and player.alive:
		player._die("BLOODY", self)
		timer = kill_timer_base

func start_kill_sequence_movement():
	show()
	if anim_player.has_animation("Bloody_moving"):
		var anim = anim_player.get_animation("Bloody_moving")
		anim.loop_mode = Animation.LOOP_LINEAR
		anim_player.play("Bloody_moving")

		while true:
			var target_pos = player.global_position
			target_pos.y = FLOOR_Y

			var dist = global_position.distance_to(target_pos)

			if dist <= KILL_DISTANCE:
				break

			var direction = (target_pos - global_position).normalized()
			global_position += direction * MOVE_SPEED * get_process_delta_time()

			look_at(target_pos, Vector3.UP)
			rotate_object_local(Vector3.UP, deg_to_rad(90))

			await get_tree().process_frame

func play_kill_animation():
	if anim_player.has_animation("Bloody_kill"):
		anim_player.play("Bloody_kill")
