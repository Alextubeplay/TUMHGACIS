extends Control

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
var last_completed_count = 0

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	last_completed_count = ShiftSettings.completed_tasks

func _process(_delta):
	update_hud_display()

func update_hud_display():
	var highlight_color = Color("185ad3")
	tasks_counter_label.visible = ShiftSettings.is_tasks_active
	tasks_counter_label.text = "Tasks:\n" + str(ShiftSettings.completed_tasks) + "/" + str(ShiftSettings.amount_of_tasks)
	
	if ShiftSettings.completed_tasks >= ShiftSettings.amount_of_tasks:
		tasks_counter_label.modulate = highlight_color
	else:
		tasks_counter_label.modulate = Color.WHITE

	time_left_label.visible = ShiftSettings.is_shift_timer_active
	time_left_label.text = "Time Left:\n" + str(int(ShiftSettings.shift_timer))
	
	if ShiftSettings.shift_timer <= 0:
		time_left_label.modulate = highlight_color
	else:
		time_left_label.modulate = Color.WHITE

func clear_tasks():
	if is_instance_valid(current_game_instance):
		current_game_instance.queue_free()
	current_game_instance = null

func load_minigame(path: String):
	clear_tasks()
	current_game_path = path
	last_completed_count = ShiftSettings.completed_tasks
	
	var scene = load(path)
	if scene:
		current_game_instance = scene.instantiate()
		tasks_container.add_child(current_game_instance)
		if current_game_instance is Control:
			current_game_instance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _on_start_pressed():
	if ShiftSettings.rage_triggered_by_valve and ShiftSettings.rage_timer > 20.0:
		return

	if ShiftSettings.completed_tasks >= ShiftSettings.amount_of_tasks:
		return
	
	if current_game_instance != null:
		if ShiftSettings.completed_tasks == last_completed_count:
			return
	
	var next_game = minigames.pick_random()
	if next_game == current_game_path and minigames.size() > 1:
		next_game = minigames[(minigames.find(next_game) + 1) % minigames.size()]
		
	load_minigame(next_game)

func _on_reload_pressed():
	if current_game_path != "":
		load_minigame(current_game_path)

func _on_exit_pressed():
	clear_tasks()
	current_game_path = ""
	last_completed_count = ShiftSettings.completed_tasks
