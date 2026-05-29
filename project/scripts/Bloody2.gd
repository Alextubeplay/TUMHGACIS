extends Node3D

@export var KILL_DISTANCE: float = 5
@export var MOVE_SPEED: float = 12.5

var timer = 10.0

@onready var valve = $"../Valve"
@onready var player = $"../Player"
@onready var anim_player = $Bloody2/AnimationPlayer

func _ready() -> void:
	hide()

func _process(delta: float) -> void:
	if not player.alive: return

	if valve.is_opened:
		if timer > 0:
			timer -= delta
		_go_to_player()
	else:
		timer = 10.0
		hide()

func _go_to_player():
	if timer <= 0 and player.alive:
		player._die("BLOODY", self)
		timer = 10.0

func start_kill_sequence_movement():
	show()
	if anim_player.has_animation("Bloody_moving"):
		var anim = anim_player.get_animation("Bloody_moving")
		anim.loop_mode = Animation.LOOP_LINEAR
		anim_player.play("Bloody_moving")
		
		while true:
			var target_pos = player.global_position
			target_pos.y = global_position.y
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
