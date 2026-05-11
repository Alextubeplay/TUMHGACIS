extends Area2D

var is_grabbed: bool = false
var start_pos: Vector2
var task_done: bool = false
var player_radius: float = 10.0

@onready var maze = $"../Maze"
@onready var finish = $"../Finish_collider"
@onready var collision_shape = $CollisionShape2D

func _ready() -> void:
	await get_tree().process_frame
	
	if collision_shape and collision_shape.shape is CircleShape2D:
		player_radius = collision_shape.shape.radius
	elif collision_shape and collision_shape.shape is RectangleShape2D:
		player_radius = collision_shape.shape.size.x / 2.0
		
	setup_game_positions()
	input_pickable = true

func setup_game_positions():
	var start_cell = maze.get_random_cell_pos()
	start_pos = maze.global_position + (start_cell * maze.cell_size) + Vector2(maze.cell_size/2, maze.cell_size/2)
	global_position = start_pos
	
	var finish_cell = maze.get_random_cell_pos()
	while finish_cell.distance_to(start_cell) < (maze.width / 2):
		finish_cell = maze.get_random_cell_pos()
	
	if finish:
		finish.global_position = maze.global_position + (finish_cell * maze.cell_size) + Vector2(maze.cell_size/2, maze.cell_size/2)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if get_global_mouse_position().distance_to(global_position) < (player_radius + 10):
				is_grabbed = !is_grabbed

func _process(_delta: float) -> void:
	if is_grabbed and not task_done:
		var target_pos = get_global_mouse_position()
		
		if maze.is_point_safe(target_pos, player_radius):
			global_position = target_pos
		else:
			respawn()

func respawn():
	is_grabbed = false
	global_position = start_pos

func _on_area_entered(area: Area2D) -> void:
	if area == finish and not task_done:
		handle_victory()

func handle_victory():
	is_grabbed = false
	task_done = true
	ShiftSettings.completed_tasks += 1
