extends Control

# Список сцен мини-игр
var minigames = [
	"res://scenes/Clicker.tscn",
	"res://scenes/Colorful_wires.tscn",
	"res://scenes/Colorless_wires.tscn",
	"res://scenes/Maze.tscn"
]

@onready var tasks_container = $"../Tasks"
@onready var start_button = $Start_button
@onready var tasks_counter_label = $Tasks_counter
@onready var time_left_label = $Time_left

var current_game_instance = null
var current_game_path = ""

func _ready():
	start_button.pressed.connect(_on_start_pressed)

func _process(_delta):
	update_hud_display()

# Обновление визуальной части HUD
func update_hud_display():
	var highlight_color = Color("185ad3")
	
	# --- СЧЕТЧИК ЗАДАЧ ---
	tasks_counter_label.visible = ShiftSettings.is_tasks_active
	tasks_counter_label.text = "Tasks:\n" + str(ShiftSettings.completed_tasks) + "/" + str(ShiftSettings.amount_of_tasks)
	
	if ShiftSettings.completed_tasks >= ShiftSettings.amount_of_tasks:
		tasks_counter_label.modulate = highlight_color
	else:
		tasks_counter_label.modulate = Color.WHITE

	# --- ТАЙМЕР ---
	time_left_label.visible = ShiftSettings.is_shift_timer_active
	time_left_label.text = "Time Left:\n" + str(int(ShiftSettings.shift_timer))
	
	if ShiftSettings.shift_timer <= 0:
		time_left_label.modulate = highlight_color
	else:
		time_left_label.modulate = Color.WHITE

# Очистка контейнера
func clear_tasks():
	if current_game_instance:
		current_game_instance.queue_free()
		current_game_instance = null

# Загрузка мини-игры
func load_minigame(path: String):
	clear_tasks()
	current_game_path = path
	var scene = load(path)
	if scene:
		current_game_instance = scene.instantiate()
		tasks_container.add_child(current_game_instance)
		if current_game_instance is Control:
			current_game_instance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

# Кнопка Старт (Треугольник)
func _on_start_pressed():
	# 1. Запрет, если норма заданий уже выполнена
	if ShiftSettings.completed_tasks >= ShiftSettings.amount_of_tasks:
		return
	
	# 2. НОВОЕ: Запрет реролла, если текущая игра уже запущена (не пройдена)
	if current_game_instance != null:
		print("Сначала завершите текущее задание!")
		return
		
	var next_game = minigames.pick_random()
	
	# Чтобы не запускать ту же самую игру, если это технически возможно
	if next_game == current_game_path and minigames.size() > 1:
		_on_start_pressed()
		return
		
	load_minigame(next_game)

# Перезапуск (Кружок)
func _on_reload_pressed():
	if current_game_path != "":
		load_minigame(current_game_path)

# Закрыть (Крестик)
func _on_exit_pressed():
	clear_tasks()
	current_game_path = ""
