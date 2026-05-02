extends Control

# Константы твоей рабочей области
const MAX_WIDTH = 750
const MAX_HEIGHT = 400

var width = 10
var height = 8
var cell_size = 60 # Будет пересчитано в _ready
var maze_color = Color("185ad3")

var grid = []
var stack = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# --- ПРАВКА ДЛЯ МАСШТАБА ---
	# Вычисляем максимально возможный размер ячейки для сетки 10x8
	var scale_x = MAX_WIDTH / width
	var scale_y = MAX_HEIGHT / height
	cell_size = min(scale_x, scale_y)
	
	# Задаем размер узла и центрируем его в области 750x400
	custom_minimum_size = Vector2(width * cell_size, height * cell_size)
	size = custom_minimum_size
	position = Vector2((MAX_WIDTH - size.x) / 2, (MAX_HEIGHT - size.y) / 2)
	# ---------------------------

	generate_maze()
	queue_redraw()

func generate_maze():
	grid.clear()
	for y in range(height):
		grid.append([])
		for x in range(width):
			grid[y].append({"visited": false, "walls": [true, true, true, true]})

	var current = Vector2(0, 0)
	grid[current.y][current.x].visited = true
	stack.push_back(current)

	while stack.size() > 0:
		var neighbors = get_unvisited_neighbors(current)
		if neighbors.size() > 0:
			var next = neighbors.pick_random()
			remove_walls(current, next)
			current = next
			grid[current.y][current.x].visited = true
			stack.push_back(current)
		else:
			current = stack.pop_back()

func get_unvisited_neighbors(p):
	var n = []
	if p.y > 0 and not grid[p.y - 1][p.x].visited: n.append(Vector2(p.x, p.y - 1))
	if p.x < width - 1 and not grid[p.y][p.x + 1].visited: n.append(Vector2(p.x + 1, p.y))
	if p.y < height - 1 and not grid[p.y + 1][p.x].visited: n.append(Vector2(p.x, p.y + 1))
	if p.x > 0 and not grid[p.y][p.x - 1].visited: n.append(Vector2(p.x - 1, p.y))
	return n

func remove_walls(a, b):
	var diff = b - a
	if diff.x == 1:
		grid[a.y][a.x].walls[1] = false
		grid[b.y][b.x].walls[3] = false
	elif diff.x == -1:
		grid[a.y][a.x].walls[3] = false
		grid[b.y][b.x].walls[1] = false
	elif diff.y == 1:
		grid[a.y][a.x].walls[2] = false
		grid[b.y][b.x].walls[0] = false
	elif diff.y == -1:
		grid[a.y][a.x].walls[0] = false
		grid[b.y][b.x].walls[2] = false

func _draw() -> void:
	var maze_rect = Rect2(Vector2.ZERO, Vector2(width * cell_size, height * cell_size))
	draw_rect(maze_rect, maze_color)
	
	for y in range(height):
		for x in range(width):
			var pos = Vector2(x, y) * cell_size
			var walls = grid[y][x].walls
			# Толщину линий тоже чуть уменьшим для красоты, если клетки стали маленькими
			var line_w = 4 if cell_size > 40 else 2
			
			if walls[0]: draw_line(pos, pos + Vector2(cell_size, 0), Color.BLACK, line_w)
			if walls[1]: draw_line(pos + Vector2(cell_size, 0), pos + Vector2(cell_size, cell_size), Color.BLACK, line_w)
			if walls[2]: draw_line(pos + Vector2(0, cell_size), pos + Vector2(cell_size, cell_size), Color.BLACK, line_w)
			if walls[3]: draw_line(pos, pos + Vector2(0, cell_size), Color.BLACK, line_w)

func is_point_safe(global_pos: Vector2) -> bool:
	var local_pos = global_pos - global_position
	var x = int(local_pos.x / cell_size)
	var y = int(local_pos.y / cell_size)
	
	if x < 0 or x >= width or y < 0 or y >= height: return false
	
	# Марджин подстраиваем под размер клетки (30% от размера), чтобы не застревать
	var margin = cell_size * 0.3
	var cell_rel_pos = Vector2(fmod(local_pos.x, cell_size), fmod(local_pos.y, cell_size))
	var walls = grid[y][x].walls
	
	if walls[0] and cell_rel_pos.y < margin: return false
	if walls[1] and cell_rel_pos.x > cell_size - margin: return false
	if walls[2] and cell_rel_pos.y > cell_size - margin: return false
	if walls[3] and cell_rel_pos.x < margin: return false
	
	return true

func get_random_cell_pos() -> Vector2:
	return Vector2(randi() % width, randi() % height)
